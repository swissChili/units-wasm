const React = require("preact");
const {useState} = require('preact/hooks');

export const UnitsApp = () => {
  const [hist, setHist] = useState([]);
  const [query, setQuery] = useState("");
  const [to, setTo] = useState("");

  function doConversion(e) {
    e.preventDefault();
    console.log("conversion");
    setQuery('');
    setTo('');
    
    convert(query, to).then(res => {
      setHist([...hist, [query, to, res]]);
    })
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
    </>
  );
};
