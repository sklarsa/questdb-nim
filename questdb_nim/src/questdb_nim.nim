
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


proc `$`(m: IlpMessage): string =
  var s = m.tableName
  s.add ","
  for k,v  in m.tagset.pairs:
    s.add ($k & "=" & $v)
  s.add " "
  for k,v in m.valueset.pairs:
    s.add ($k & "=" & $v)
  if not m.timestamp.isNil():
    s.add " "
    let unix = m.timestamp.timestamp.toUnixFloat()
    s.add $unix
  s

proc isValid(m: IlpMessage): bool =
  if m.tableName == "" or m.tableName.contains(' '):
    return false

  for k,v in m.tagset.pairs:
    if k.contains(' ') or v.contains(' '):
      return false

  for k,v in m.valueset.pairs:
    if k.contains(' '):
      return false

  true


when isMainModule:
  let msg1 = IlpMessage(
    tableName: "hi",
    tagset: {"mytag-1":"mytagvalue-1", "mytag-2":"mytagvalue-2"}.toTable(),
    valueset: {"myvalue-1": 1.0, "myvalue-2": 2.0}.toTable(),
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
