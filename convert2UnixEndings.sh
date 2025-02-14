
find . -name *.m -exec dos2unix {} \;
find . -iname "*.md" -exec dos2unix "{}" \;
find . -iname *.yaml -exec dos2unix {} \;
find . -iname *.yml -exec dos2unix {} \;
find . -iname *.txt -exec dos2unix {} \;
find . -name *.gitignore -exec dos2unix {} \;
find . -name LICENSE -exec dos2unix {} \;