const React = require("preact");
const { useState, useEffect } = require('preact/hooks');

export const UnitsApp = () => {
  const [hist, setHist] = useState([]);
  const [query, setQuery] = useState("");
  const [to, setTo] = useState("");
  const [unitSystem, setUnitSystem] = useState('si');

  function doConversion(e, q, t, convert) {
    e.preventDefault();
    console.log("conversion");

    if (q === '') {
      console.log('empty query');
      return;
    }

    console.log("units", unitSystem);

    convert(q, t, unitSystem).then(res => {
      setHist([...hist, [q, t, res]]);
    });

    setQuery('');
    setTo('');
  }

  useEffect(() => {
    const q = new URLSearchParams(window.location.search);
    if (q.get('from') !== null) {
      window.convertPromise.then(convert => {
        setQuery(q.get('from'));
        setTo(q.get('to') || '');
        doConversion({preventDefault: () => {}}, q.get('from'), q.get('to'), convert);
      });
    }
  }, []);

  function afterEquals(str) {
    let parts = str.split('=');
    return parts[parts.length - 1];
  }

  return (
    <>
      <form class="query-row noselect" onSubmit={e => doConversion(e, query, to, window.convert)}>
        <input
          type="text"
          id="query"
          value={query}
          placeholder="From"
          class="noselect"
          onChange={(val) => setQuery(val.target.value)}
        ></input>
        <input
          type="text"
          id="to"
          value={to}
          placeholder="To"
          class="noselect"
          onChange={(val) => setTo(val.target.value)}
        ></input>

        <input value="Convert" type="submit"></input>
      </form>

      <div class="table-container">
        <div class="table-title">
          <span>Calculation</span>
          <span>Result</span>
        </div>
        <div class="history">
          {hist.map((entry) => (
              <div class="entry">
                <span class="from">{entry[0]}</span>
                { entry[1] !== "" ? <span class="to"> {entry[1]}</span> : <span />}
                <span class="filler">
                <span class="equals noselect">=</span>
                <span class="res">{afterEquals(entry[2])}</span>
                </span>
              </div>
            ))
          }
        </div>
      </div>

      <div class="bottom-menu noselect">
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
