CFLAGS = -Os -DSUPPORT_UTF8 -sASYNCIFY -sEXPORTED_RUNTIME_METHODS=ccall,cwrap,stringToNewUTF8 \
	-sEXPORTED_FUNCTIONS=_test_int,_do_a_conversion -sMODULARIZE -s 'EXPORT_NAME="createMyModule"' \
	--no-entry

ESFLAGS = --bundle --minify --loader:.js=jsx

WEBCFLAGS = -Os -framework WebKit -std=c++11 

webview-frontend: webview-frontend.cpp units.o getopt.o getopt1.o parse.tab.o strfunc.o | bundle-webview-js.h
	g++ $^ -o webview-frontend $(WEBCFLAGS) -I json/include
	strip $@

units.wasm: units.c
	emcc -o units.lib.js *.c $(CFLAGS) --preload-file definitions.units --preload-file elements.units --preload-file currency.units --preload-file cpi.units

units-host: units.c
	gcc *.c -o units-host -g

%.o: %.c
	gcc -c $^ -Os -o $@

bundle.js: frontend.js units.wasm
	yarn esbuild frontend.js $(ESFLAGS) --outfile=bundle.js

bundle-webview-js.h: bundle-webview.js
	xxd -i $^ > $@

bundle-webview.js: webview-frontend.js frontend-impl.js styles.css
	yarn esbuild styles.css --outfile=styles.css.txt --minify
	yarn esbuild webview-frontend.js $(ESFLAGS) --outfile=bundle-webview.js

watch: units.wasm
	yarn esbuild frontend.js $(ESFLAGS) --watch --outfile=bundle.js

.PHONY: watch webview-frontend
