const units = require('./units.lib.js');

const readline = require("readline");
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});


units().then(Module => {
    let test = Module.cwrap('test_int', 'number', ['number', 'number']);
    let _do_a_conversion = Module.cwrap('do_a_conversion', 'number', ['number', 'number']);

    function do_a_conversion(from, to) {
        let from_c = Module.stringToNewUTF8(from);
        let to_c = Module.stringToNewUTF8(to);
        let lenBefore = globalThis.printBuffer.length;
        _do_a_conversion(from_c, to === "" ? 0 : to_c);
        return globalThis.printBuffer.slice(lenBefore).trim();
    }

    let ask = () => rl.question("From ", from => {
        rl.question("To ", to => {
            console.log(do_a_conversion(from, to));
            ask();
        });
    });

    ask();

});
