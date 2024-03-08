const React = require("preact");
const { useState } = require('preact/hooks');

export const UnitsApp = () => {
  const [hist, setHist] = useState([]);
  const [query, setQuery] = useState("");
  const [to, setTo] = useState("");
  const [unitSystem, setUnitSystem] = useState('si');

  function doConversion(e) {
    e.preventDefault();
    console.log("conversion");

    if (query == '')
      return;

    console.log("units", unitSystem);

    convert(query, to, unitSystem).then(res => {
      setHist([...hist, [query, to, res]]);
    });

    setQuery('');
    setTo('');
  }

  return (
    <>
      <form class="query-row" onSubmit={doConversion}>
        <input
          type="text"
          id="query"
          value={query}
          placeholder="From"
          onChange={(val) => setQuery(val.target.value)}
        ></input>
        <input
          type="text"
          id="to"
          value={to}
          placeholder="To"
          onChange={(val) => setTo(val.target.value)}
        ></input>

        <input value="Convert" type="submit"></input>
      </form>

      <div class="table-container">
        <table>
          <thead>
            <tr><td style="width: 30%">From</td><td style="width: 15%">To</td><td style="width: 55%">Result</td></tr>
          </thead>
          {hist.map((entry) => (
            <tr>{entry.map(t => <td>{t}</td>)}</tr>
          ))}
          <tr><td></td></tr>
        </table>
      </div>

      <div class="bottom-menu">
        <span>
          Units: &nbsp;
          <select onChange={val => setUnitSystem(val.target.value)}>
            <option value="si">SI</option>
            <option value="gauss">CGS Gaussian</option>
            <option value="esu">CGS ESU</option>
            <option value="emu">CGS EMU</option>
            <option value="lhu">CGS LHU</option>
          </select>
        </span>

        <button onClick={() => setHist([])}>Clear</button>
      </div>

    </>
  );
};
