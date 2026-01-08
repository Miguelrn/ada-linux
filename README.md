gnatmake main.adb

gnatmake -f main.adb -largs -l:libraylib.a -lm && ./main



based on the javascript described here (converted to ada + raylib):
https://github.com/tsoding/formula/blob/main/index.js
