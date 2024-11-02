.RECIPEPREFIX += 
POSTS=$(shell find src/posts -name *.tex -exec basename {} .tex \; | tac)

.PHONY: all clean posts cleansite test

all: posts index.html
    mkdir -p build

define post_rule
posts/$(1)/index.html: src/posts/$(1)/$(1).tex src/posts/post_styler.cfg
    cd build; \
    cp ../src/posts/$(1)/$(1).bib .; \
    latex.exe -interaction=nonstopmode -output-format=dvi ../src/posts/$(1)/$(1).tex; \
    biber.exe $(1).bcf; \
    make4ht.exe -c ../src/posts/post_styler.cfg -d ../posts/$(1) ../src/posts/$(1)/$(1).tex "fn-in,mathml,mathjax"; \
    mv ../posts/$(1)/$(1).html ../posts/$(1)/index.html;
endef

$(foreach p,$(POSTS),$(eval $(call post_rule,$(p))))
$(POSTS): %: posts/%/index.html
posts: $(POSTS)

define write_toc_entry
echo "<div id=\"$(1)\" class=\"k-post-list-item\" onClick=\"location.href='posts/$(1)'\">\
<span class=\"k-post-title\">$$(cat posts/$(1)/index.html | hxselect -i -c h2.titleHead)</span>\
<span class=\"k-post-dateline\">$$(cat posts/$(1)/index.html | hxselect -i -c div.date span)</span>\
<div class=\"k-post-excerpt\">$$(cat posts/$(1)/index.html | hxselect -i -c div.post-excerptable)</div>\
</div>" >> build/toc.htmlfrag;
endef

index.html: src/index.html $(POSTS)
    rm -f build/toc.htmlfrag; \
    $(foreach p,$(POSTS),$(call write_toc_entry,$(p))) \
    sed '/<!--K-POST-LIST-->/r build/toc.htmlfrag' src/index.html > index.html

clean: 
    rm -rf build/*

cleansite:
    rm -rf posts
    rm -f index.html

test:
    python3 -m http.server 8080