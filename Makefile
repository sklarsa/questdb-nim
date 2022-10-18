test:
	nimble test

docs:
	rm htmldocs/*.idx || true
	nim doc --project --index:on --outdir:htmldocs src/questdb_nim.nim

install-githooks:
	cp .githooks/pre-commit ./.git/hooks/pre-commit
