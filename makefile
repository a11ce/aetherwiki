MDSOURCES :=  $(wildcard md-src/*.md) $(wildcard md-src/**/*.md)
HTMLPAGES := $(MDSOURCES:md-src/%.md=docs/%.html)

PANDOC_OPTS := -f markdown+fenced_divs+wikilinks_title_before_pipe+implicit_figures+link_attributes -t html5 -V lang=en-US -s \
               -c style.css \
               --lua-filter=wiki.lua \
               --template=template.html \
               --include-after-body=footer.html

all: clean etc pages search check
.PHONY: all clean index

pages: index $(HTMLPAGES)
	@

search:
	npx -y pagefind --site ./docs

index:
	python3 index.py > md-src/index.md
	

docs/%.html: md-src/%.md
	@pandoc $< $(PANDOC_OPTS) -o $@

etc:
	cp -r includes/. docs

check:
	@lua check-backlinks.lua
	
clean:
	@rm -rf docs
	@rm -f backlinks.csv
