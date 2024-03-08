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
      setHist([...hist, query + " -> " + to + " " + res]);
    })
  }

  return (
    <div>
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
          
        <input type="submit"></input>
      </form>

      <ul>
        {hist.map((entry) => (
          <li>{entry}</li>
        ))}
      </ul>
    </div>
  );
};
