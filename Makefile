CFLAGS = -Os -DSUPPORT_UTF8 -sASYNCIFY -sEXPORTED_RUNTIME_METHODS=ccall,cwrap,stringToNewUTF8 \
	-sEXPORTED_FUNCTIONS=_test_int,_do_a_conversion -sMODULARIZE -s 'EXPORT_NAME="createMyModule"' \
	--pre-js=module-pre.js

units.wasm: *.c *.h
	emcc -o units.lib.js *.c $(CFLAGS) --preload-file definitions.units --preload-file elements.units --preload-file currency.units --preload-file cpi.units

units-host:
	gcc *.c -o units-host -g

.PHONY: units.wasm units-host
