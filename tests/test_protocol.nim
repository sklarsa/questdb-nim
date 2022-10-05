import unittest
import std/[strformat,tables,times]

import message

test "protocol":

  let symbols = {"t1":"tv1", "t2":"tv2"}.toOrderedTable()
  let time = now().toTime()
  let timeMicroseconds = time.toMicroseconds()
  let timeNanoseconds = time.toNanoseconds()

  let vals = {
    "v1": IlpValue(kind: ilpFloat, floatVal: 1.0),
    "v2": IlpValue(kind: ilpString, stringVal: "2.0"),
    "v3": IlpValue(kind: ilpInt, intVal: 3),
    "v4": IlpValue(kind: ilpTime, timeVal: time),
    "v5": IlpValue(kind: ilpBool, boolVal: false),
  }.toOrderedTable()


  # Message with no timestamp
  let m1 = IlpMessage(
      tableName: "hi",
      symbolset: symbols,
      columnset: vals,
  )
  check $m1 == &"hi,t1=tv1,t2=tv2 v1=1.0,v2=\"2.0\",v3=3i,v4={timeMicroseconds}t,v5=false"
  m1.validate()

  # Message with a timestamp
  let m2 = IlpMessage(
    tableName: "hi",
    symbolset: symbols,
    columnset: {"v1": IlpValue(kind: ilpString, stringVal: "test")}.toOrderedTable(),
    timestamp: time,
  )
  check $m2 == &"hi,t1=tv1,t2=tv2 v1=\"test\" {timeNanoseconds}"
  m2.validate()

  # Test unescaped space
  let unescapedSpaces = @["\\  ", "a ", "a a", "a\\ a a"]
  for s in unescapedSpaces:
    var m3 = IlpMessage(
      tableName: s
    )
    doAssertRaises(ValueError, m3.validate())

  # todo: test " " --> should be invalid
