import std/strformat
import std/strutils
import std/tables
import std/times

# https://internet-of-tomohiro.netlify.app/nim/faq.en.html#coding-how-to-store-different-types-in-seqqmark
# https://nim-lang.org/docs/manual.html#types-object-variants
type
  IlpValueKind* = enum
    ilpInt,
    ilpFloat,
    ilpString,
    ilpTime
  IlpValue* = ref IlpValueObj
  IlpValueObj = object
    case kind*: IlpValueKind
    of ilpInt: intVal*: int
    of ilpFloat: floatVal*: float
    of ilpString: stringVal*: string
    of ilpTime: timeVal*: Time

proc `$`*(v: IlpValue): string =
  case v.kind
  of ilpInt: $v.intVal
  of ilpFloat: $v.floatVal
  of ilpString: $v.stringVal
  of ilpTime: $v.timeVal

# todo: implement long256 -- https://questdb.io/docs/reference/api/ilp/columnset-types#long256


type
  IlpMessage* = object
    tableName*: string
    symbolset*: Table[string, string]
    columnset*: Table[string, IlpValue]
    timestamp*: Time

proc `$`*(m: IlpMessage): string =
  # todo: handle escaping

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
    let unix = m.timestamp.toUnixFloat()
    s.add $unix
  s

const forbiddenTableChars = ['\n','\r','?',',',':','"','\'','\\','/','\0',')','(','+','*','~','%']
const forbiddenColumnChars = ['\n','\r','?',',',':','"','\'','\\','/','\0',')','(','+','*','~','%','.','-']

proc validate*(m: IlpMessage) =
  # todo: check escaped chars

  # Check table
  if m.tableName == "":
    raise newException(ValueError, "len of m.tableName is 0")

  if m.tableName[0] == '.' or m.tableName[len(m.tableName) - 1] == '.':
    raise newException(ValueError, "m.tableName cannot begin or end with '.'")

  for c in m.tableName:
    if forbiddenTableChars.contains(c):
      raise newException(ValueError, "invalid m.tableName: " & m.tableName)

  # Check columns
  for s in m.symbolset.keys:
    if s == "":
      raise newException(ValueError, fmt"invalid symbolset key: '{s}'")

    for c in s:
      if forbiddenColumnChars.contains(c):
        raise newException(ValueError, fmt"invalid symbolset key: '{c}")

  for s in m.columnset.keys:
    if s == "":
      raise newException(ValueError, fmt"invalid columnset key: '{s}'")

    for c in s:
      if forbiddenColumnChars.contains(c):
        raise newException(ValueError, fmt"invalid columnset key: '{c}")


proc fromString(s: string): IlpMessage =
  raise newException(Exception, "Not implemented")

when isMainModule:
  let msg1 = IlpMessage(
    tableName: "hi",
    symbolset: {"mytag_1":"mytagvalue_1", "mytag_2":"mytagvalue_2"}.toTable(),
    columnset: {
      "myvalue_1": IlpValue(kind: ilpFloat, floatVal: 3.14159265358979323846264338327950),
      "myvalue_2": IlpValue(kind: ilpString, stringVal: "2.0"),
    }.toTable(),
  )

  echo $msg1
  msg1.validate()

  let msg2 = IlpMessage(
    tableName: msg1.tableName,
    symbolset: msg1.symbolset,
    columnset: msg1.columnset,
    timestamp: now().toTime()
  )
  echo $msg2
  msg2.validate()
