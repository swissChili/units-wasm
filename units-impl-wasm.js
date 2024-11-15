const units = require("./units.lib.js");

globalThis.printBuffer = "";

units({
  "print": function(out) {
    globalThis.printBuffer += out + "\n";
  }
}).then((Module) => {
  let _do_a_conversion = Module.cwrap("do_a_conversion", "number", [
    "number",
    "number",
    "number",
  ]);

  async function convert(from, to = "", system="si") {
    let from_c = Module.stringToNewUTF8(from);
    let to_c = Module.stringToNewUTF8(to);
    let sys_c = Module.stringToNewUTF8(system);
    let lenBefore = globalThis.printBuffer.length;
    _do_a_conversion(from_c, to === "" ? 0 : to_c, system);
    return globalThis.printBuffer.slice(lenBefore).trim();
  }

  window.convert = convert;
});
