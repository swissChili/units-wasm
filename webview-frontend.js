const {UnitsApp} = require("./frontend-impl.js");
const React = require("preact");
const stylesheet = require("./styles.css.txt");

const style = document.createElement("style");
style.innerText = stylesheet;

document.body.appendChild(style);

React.render(<UnitsApp />, document.getElementById("app"));
