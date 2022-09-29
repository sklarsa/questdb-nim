# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import std/tables
import std/times

import message

test "protocol":

  let symbols = {"t1":"tv1", "t2":"tv2"}.toTable()
  let t = IlpValue(f: 1.0)
  echo t


  let vals = {"v1": IlpValue(f: 1.0), "v2": IlpValue(s: "2.0")}.toTable()
  let time = now().toTime()

  # Message with no timestamp
  let m1 = IlpMessage(
      tableName: "hi",
      symbolset: symbols,
      columnset: vals,
  )
  check $m1 == "hi,t1=tv1,t2=tv2 v1=1.0,v2=2.0"
  m1.validate()

  # Message with a timestamp
  let m2 = IlpMessage(
    tableName: "hi",
    symbolset: symbols,
    columnset: vals,
    timestamp: time,
  )
  check $m2 == "hi,t1=tv1,t2=tv2 v1=1.0,v2=2.0 " & $(m2.timestamp.toUnixFloat())
  m2.validate()

  # Edge case
  ## for future reference... doAssertRaises(ValueError): ...
  ##
