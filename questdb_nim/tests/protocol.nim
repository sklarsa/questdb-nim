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

  let tags = {"t1":"tv1", "t2":"tv2"}.toTable()
  let vals = {"v1": 1.0, "v2": 2.0}.toTable()
  let time = now().toTime()

  let m1 = IlpMessage(
      tableName: "hi",
      tagset: tags,
      valueset: vals,
  )
  check $m1 == "hi,t1=tv1,t2=tv2 v1=1.0,v2=2.0"

  let m2 = IlpMessage(
    tableName: "hi",
    tagset: tags,
    valueset: vals,
    timestamp: IlpTimestamp(timestamp: time),
  )
  check $m2 == "hi,t1=tv1,t2=tv2 v1=1.0,v2=2.0 " & $(m2.timestamp.timestamp.toUnixFloat())
