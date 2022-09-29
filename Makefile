test:
	nim c -r questdb_nim/tests/protocol.nim

docs:
	nim doc --project --index:on --outdir:htmldocs questdb_nim/src/client.nim
