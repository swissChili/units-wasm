const {setupUnits} = require("./units-impl-wasm.js");

setupUnits();

const {UnitsApp} = require("./frontend-impl.js");
const React = require("preact");

React.render(<UnitsApp />, document.getElementById("app"));
