# Package

version       = "0.1.0"
author        = "Steve Sklar"
description   = "An ILP (Influx Line Protocol) client for QuestDB"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["questdb_nim"]


# Dependencies

requires "nim >= 1.6.8"
