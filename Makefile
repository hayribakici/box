DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test:
	@$(PANDOC) samples/sample_div.md --lua-filter=pandoc-div-box.lua -w latex | $(DIFF) expected.tex -

pdf:
  @$(PANDOC) samples/sample_div.md --lua-filter=pandoc-div-box.lua --output=samples/sample_div.pdf

.PHONY: test pdf
