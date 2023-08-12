DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test:
	@$(PANDOC) sample.md --lua-filter=box.lua -w latex | $(DIFF) expected.tex -

pdf:
  @$(PANDOC) sample.md --lua-filter=box.lua --output=sample.pdf

.PHONY: test pdf
