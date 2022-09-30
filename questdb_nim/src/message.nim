import std/math
import std/strformat
import std/strutils
import std/tables
import std/times


proc toMicroseconds*(t: Time): int =
  int(round(t.toUnixFloat() * 1_000_000))

proc toNanoseconds*(t: Time): int =
  int(round(t.toUnixFloat() * 1_000_000_000))

# https://internet-of-tomohiro.netlify.app/nim/faq.en.html#coding-how-to-store-different-types-in-seqqmark
# https://nim-lang.org/docs/manual.html#types-object-variants
type
  IlpValueKind* = enum
    ilpBool,
    ilpInt,
    ilpFloat,
    ilpString,
    ilpTime
  IlpValue* = ref IlpValueObj
  IlpValueObj = object
    case kind*: IlpValueKind
    of ilpBool: boolVal*: bool
    of ilpInt: intVal*: int
    of ilpFloat: floatVal*: float
    of ilpString: stringVal*: string
    of ilpTime: timeVal*: Time

proc `$`*(v: IlpValue): string =
  case v.kind
  of ilpBool: $v.boolVal
  of ilpInt: $v.intVal & 'i'
  of ilpFloat: $v.floatVal
  of ilpString: '"' & $v.stringVal & '"'
  of ilpTime: $v.timeVal.toMicroseconds() & 't'

# todo: implement long256 -- https://questdb.io/docs/reference/api/ilp/columnset-types#long256

type
  IlpMessage* = object
    tableName*: string
    symbolset*: OrderedTable[string, string]
    columnset*: OrderedTable[string, IlpValue]
    timestamp*: Time

proc `$`*(m: IlpMessage): string =
  var s = m.tableName
  s.add ","
  for k,v  in m.symbolset.pairs:
    s.add ($k & "=" & $v & ",")
  s.removeSuffix(",")
  s.add " "
  for k,v in m.columnset.pairs:
    s.add ($k & "=" & $v & ",")
  s.removeSuffix(",")

  # todo: I guess this doesn't support unix epoch right now...
  if (m.timestamp != Time()):
    s.add " "
    let unix = $m.timestamp.toNanoseconds()
    s.add $unix
  s

const forbiddenTableChars = ['\n','\r','?',',',':','"','\'','\\','/','\0',')','(','+','*','~','%']
const forbiddenColumnChars = ['\n','\r','?',',',':','"','\'','\\','/','\0',')','(','+','*','~','%','.','-']

proc validateTableOrColumnName(s: string, invalidChars: openArray[char]) =
  if s == "":
    raise newException(ValueError, fmt"empty string: '{s}'")

  for i, c in s:
      if invalidChars.contains(c):
        if c == '\\' and i < (len(s) - 1) and s[i+1] == ' ':
          continue
        raise newException(ValueError, fmt"'{s}' has invalid char: '{c}'")

      if i > 0 and c == ' ' and s[i-1] != '\\':
        raise newException(ValueError, &"'{s}' has unescaped ' ' at idx {i}")

proc validate*(m: IlpMessage) =

  # Check table
  validateTableOrColumnName(m.tableName, forbiddenTableChars)

  # Additionally check to make sure tableName does not start or end with '.'
  if m.tableName[0] == '.' or m.tableName[len(m.tableName) - 1] == '.':
    raise newException(ValueError, "m.tableName cannot begin or end with '.'")

  # Check column names
  for s in m.symbolset.keys:
    validateTableOrColumnName(s, forbiddenColumnChars)

  for s in m.columnset.keys:
    validateTableOrColumnName(s, forbiddenColumnChars)
