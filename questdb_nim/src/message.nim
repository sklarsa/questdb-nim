import std/strutils
import std/tables
import std/times

type
  IlpTimestamp = ref object
    timestamp: Time


type
  IlpMessage* = object
    tableName*: string
    tagset*: Table[string, string]
    valueset*: Table[string, float64]
    timestamp*: IlpTimestamp


proc `$`*(m: IlpMessage): string =
  var s = m.tableName
  s.add ","
  for k,v  in m.tagset.pairs:
    s.add ($k & "=" & $v & ",")
  s.removeSuffix(",")
  s.add " "
  for k,v in m.valueset.pairs:
    s.add ($k & "=" & $v & ",")
  s.removeSuffix(",")
  s.add " "
  if not m.timestamp.isNil():

    let unix = m.timestamp.timestamp.toUnixFloat()
    s.add $unix
  s

proc isValid*(m: IlpMessage): bool =
  if m.tableName == "" or m.tableName.contains(' '):
    return false

  for k,v in m.tagset.pairs:
    if k.contains(' ') or v.contains(' '):
      return false

  for k,v in m.valueset.pairs:
    if k.contains(' '):
      return false

  true

proc fromString(s: string): IlpMessage =
  raise newException(Exception, "Not implemented")

when isMainModule:
  let msg1 = IlpMessage(
    tableName: "hi",
    tagset: {"mytag_1":"mytagvalue_1", "mytag_2":"mytagvalue_2"}.toTable(),
    valueset: {"myvalue_1": 3.14159265358979323846264338327950, "myvalue_2": 2.0}.toTable(),
  )
  echo $msg1
  doAssert msg1.isValid()

  let msg2 = IlpMessage(
    tableName: msg1.tableName,
    tagset: msg1.tagset,
    valueset: msg1.valueset,
    timestamp: IlpTimestamp(timestamp: now().toTime())
  )
  echo $msg2
  doAssert msg2.isValid()
