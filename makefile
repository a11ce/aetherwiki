MDSOURCES :=  $(wildcard md-src/*.md) $(wildcard md-src/**/*.md)
HTMLPAGES := $(MDSOURCES:md-src/%.md=docs/%.html)

PANDOC_OPTS := -f markdown+fenced_divs+wikilinks_title_before_pipe -t html5 -s \
               -c style.css --lua-filter=wiki.lua

all: clean etc pages check
.PHONY: all clean clean

pages: $(HTMLPAGES)
	@mkdir -p docs

docs/%.html: md-src/%.md
	@pandoc $< $(PANDOC_OPTS) -o $@

etc:
	cp -r includes/. docs

check:
	@lua check-backlinks.lua
	
clean:
	@rm -rf docs
	@rm -f backlinks.csv
