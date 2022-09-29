test:
	nim c -r questdb_nim/src/message.nim
	nim c -r questdb_nim/src/client.nim
	cd questdb_nim && nimble test

docs:
	nim doc --project --index:on --outdir:htmldocs questdb_nim/src/client.nim
