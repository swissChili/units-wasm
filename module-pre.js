globalThis.printBuffer = '';

Module['print'] = function (out) {
    globalThis.printBuffer += out + "\n";
};
