.RECIPEPREFIX += 
POSTS=$(shell find src/posts -name *.tex -exec basename {} .tex \; | tac)

.PHONY: all clean posts cleansite test

all: posts site/index.html
    mkdir -p build

define post_rule
site/posts/$(1)/index.html: src/posts/$(1)/$(1).tex src/posts/post_styler.cfg
    cd build; \
    cp ../src/posts/$(1)/$(1).bib .; \
    latex.exe -interaction=nonstopmode -output-format=dvi ../src/posts/$(1)/$(1).tex; \
    biber.exe $(1).bcf; \
    make4ht.exe -c ../src/posts/post_styler.cfg -d ../site/posts/$(1) ../src/posts/$(1)/$(1).tex "fn-in,mathml,mathjax"; \
    mv ../site/posts/$(1)/$(1).html ../site/posts/$(1)/index.html;
endef

$(foreach p,$(POSTS),$(eval $(call post_rule,$(p))))
$(POSTS): %: site/posts/%/index.html
posts: $(POSTS)

define write_toc_entry
echo "<div id=\"$(1)\" class=\"k-post-list-item\" onClick=\"location.href='posts/$(1)'\">\
<span class=\"k-post-title\">$$(cat site/posts/$(1)/index.html | hxselect -i -c h2.titleHead)</span>\
<span class=\"k-post-dateline\">$$(cat site/posts/$(1)/index.html | hxselect -i -c div.date span)</span>\
<div class=\"k-post-excerpt\">$$(cat site/posts/$(1)/index.html | hxselect -i -c div.post-excerptable)</div>\
</div>" >> build/toc.htmlfrag;
endef

site/index.html: src/index.html $(POSTS)
    rm -f build/toc.htmlfrag; \
    $(foreach p,$(POSTS),$(call write_toc_entry,$(p))) \
    sed '/<!--K-POST-LIST-->/r build/toc.htmlfrag' src/index.html > site/index.html

clean: 
    rm -rf build/*

cleansite:
    rm -rf site/posts
    rm -f site/index.html

test:
    cd site; \
    python3 -m http.server 8080