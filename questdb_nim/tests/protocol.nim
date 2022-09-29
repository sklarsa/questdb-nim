# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import std/strformat
import std/tables
import std/times

import message

test "protocol":

  let symbols = {"t1":"tv1", "t2":"tv2"}.toOrderedTable()
  let timestamp = now().toTime()

  let vals = {
    "v1": IlpValue(kind: ilpFloat, floatVal: 1.0),
    "v2": IlpValue(kind: ilpString, stringVal: "2.0"),
    "v3": IlpValue(kind: ilpInt, intVal: 3),
    "v4": IlpValue(kind: ilpTime, timeVal: timestamp),
    "v5": IlpValue(kind: ilpBool, boolVal: false),
  }.toOrderedTable()

  let time = now().toTime()

  # Message with no timestamp
  let m1 = IlpMessage(
      tableName: "hi",
      symbolset: symbols,
      columnset: vals,
  )
  let t1 = $(vals["v4"].timeVal.toUnixFloat()) & 't'
  check $m1 == &"hi,t1=tv1,t2=tv2 v1=1.0,v2=\"2.0\",v3=3i,v4={t1},v5=false"
  m1.validate()

  # Message with a timestamp
  let m2 = IlpMessage(
    tableName: "hi",
    symbolset: symbols,
    columnset: {"v1": IlpValue(kind: ilpString, stringVal: "test")}.toOrderedTable(),
    timestamp: time,
  )
  check $m2 == "hi,t1=tv1,t2=tv2 v1=\"test\" " & $(m2.timestamp.toUnixFloat())
  m2.validate()

  # Edge case
  ## for future reference... doAssertRaises(ValueError): ...
  ##
