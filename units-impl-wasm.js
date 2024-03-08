const units = require("./units.js");

units().then((Module) => {
  let _do_a_conversion = Module.cwrap("do_a_conversion", "number", [
    "number",
    "number",
  ]);

  async function convert(from, to = "") {
    let from_c = Module.stringToNewUTF8(from);
    let to_c = Module.stringToNewUTF8(to);
    let lenBefore = globalThis.printBuffer.length;
    _do_a_conversion(from_c, to === "" ? 0 : to_c);
    return globalThis.printBuffer.slice(lenBefore).trim();
  }

  window.convert = convert;
});