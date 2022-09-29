test:
	cd questdb_nim && nimble test

docs:
	nim doc --project --index:on --outdir:htmldocs questdb_nim/src/client.nim

install-githooks:
	cp githooks/pre-commit ./.git/hooks/pre-commit
