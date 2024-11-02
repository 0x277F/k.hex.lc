#!/bin/bash
POST_NAME=$1
POST_ID="$(find src/posts -type d | wc -l)-$(echo ${POST_NAME,,} | sed -e 's/ /-/g' -e 's/[^a-zA-Z0-9-]//g')"
mkdir -p "src/posts/$POST_ID"
sed -e "s|--TITLE--|$POST_NAME|g" -e "s|--ID--|$POST_ID|g" src/post-template.tex > "src/posts/$POST_ID/$POST_ID.tex"
touch "src/posts/$POST_ID/$POST_ID.bib"
cmd.exe /c start src/posts/$POST_ID/$POST_ID.tex