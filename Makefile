DIFF ?= diff --strip-trailing-cr -u
PANDOC ?= pandoc

test:
	@$(PANDOC) sample_div.md --lua-filter=pandoc-div-box.lua -w latex | $(DIFF) expected.tex -

pdf:
  @$(PANDOC) sample_div.md --lua-filter=pandoc-div-box.lua --output=sample_div.pdf

.PHONY: test pdf
