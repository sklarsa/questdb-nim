import std/strformat
import std/strutils
import std/tables
import std/times

type
  IlpTimestamp* = ref object
    timestamp*: Time


type
  IlpMessage* = object
    tableName*: string
    symbolset*: Table[string, string]
    columnset*: Table[string, float64]
    timestamp*: IlpTimestamp


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

  if not m.timestamp.isNil():
    s.add " "
    let unix = m.timestamp.timestamp.toUnixFloat()
    s.add $unix
  s

const forbiddenTableChars = ['\n','\r','?',',',':','"','\'','\\','/','\0',')','(','+','*','~','%']
const forbiddenColumnChars = ['\n','\r','?',',',':','"','\'','\\','/','\0',')','(','+','*','~','%','.','-']

proc validate*(m: IlpMessage) =
  # todo: check escaped spaces

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
    columnset: {"myvalue_1": 3.14159265358979323846264338327950, "myvalue_2": 2.0}.toTable(),
  )
  echo $msg1
  msg1.validate()

  let msg2 = IlpMessage(
    tableName: msg1.tableName,
    symbolset: msg1.symbolset,
    columnset: msg1.columnset,
    timestamp: IlpTimestamp(timestamp: now().toTime())
  )
  echo $msg2
  msg2.validate()
