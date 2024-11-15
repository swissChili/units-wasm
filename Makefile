CFLAGS = -Os -DSUPPORT_UTF8 -sASYNCIFY -sEXPORTED_RUNTIME_METHODS=ccall,cwrap,stringToNewUTF8 \
	-sEXPORTED_FUNCTIONS=_test_int,_do_a_conversion -sMODULARIZE -s 'EXPORT_NAME="createMyModule"' \
	--no-entry -flto -sASSERTIONS

ESFLAGS = --bundle --minify --loader:.js=jsx --platform=node

WEBCFLAGS = -Os -framework WebKit -framework Cocoa -std=c++11 -flto

CC=clang
MC=clang
CXX=clang++

webview-frontend: webview-frontend.cpp units.o getopt.o getopt1.o parse.tab.o strfunc.o menu.o | bundle-webview-js.h
	$(CXX) $^ -o webview-frontend $(WEBCFLAGS) -I json/include
	strip $@

app-bundle: webview-frontend
	cp webview-frontend Units.app/Contents/MacOS/
	rm -rf /Applications/Units.app
	cp -r Units.app /Applications

menu.o: webview/menu.m
	$(MC) $^ -c -o $@ -flto -Os

units.wasm: units.c
	emcc -o units.lib.js *.c $(CFLAGS) --preload-file definitions.units --preload-file elements.units --preload-file currency.units --preload-file cpi.units

units-host: units.c
	$(CC) *.c -o units-host -g

%.o: %.c
	$(CC) -c $^ -Os -o $@ -Os

bundle.js: frontend.js units.wasm
	yarn esbuild frontend.js $(ESFLAGS) --outfile=bundle.js

bundle-webview-js.h: bundle-webview.js
	xxd -i $^ > $@

bundle-webview.js: webview-frontend.js frontend-impl.js styles.css
	yarn esbuild styles.css --outfile=styles.css.txt --minify
	yarn esbuild webview-frontend.js $(ESFLAGS) --outfile=bundle-webview.js

watch: units.wasm
	yarn esbuild frontend.js $(ESFLAGS) --watch --outfile=bundle.js

clean:
	rm -f *.o webview-frontend *.wasm

.PHONY: watch webview-frontend
