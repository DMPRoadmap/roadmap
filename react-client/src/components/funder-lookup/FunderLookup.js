import {
  useState,
  useEffect
} from "react";
import { DmpApi } from "../../api.js";


function FunderLookup(props) {
  const [query, setQuery] = useState("");
  const [suggestion, setSuggestion] = useState([]);

  var controller;

  let disabledClass = props?.disabled ? "group-disabled" : "";
  let errorMsg = props?.error ? props.error : "";

  useEffect(() => {
    if (controller) controller.abort();

    if (query == "") {
      setSuggestion(null);
      return;
    }

    // NOTE: Since the server requires a limit of 3 characters,
    // we might as well avoid any work till we reach the minimum.
    if (query.length < 3) return;

    controller = new AbortController();

    let api = new DmpApi();
    let options = api.getOptions({signal: controller.signal});

    fetch(api.getPath(`/funders?search=${query}`), options)
      .then((resp) => {
        api.handleResponse(resp);
        return resp.json();
      })
      .then((data) => {
        setSuggestion(data.items);
      })
      .catch((err) => {
        if (err.response && err.response.status === 404) {
          setSuggestion(null);
        }
        errorMsg = err.response.toString();
      });
  }, [query]);


  let errorClass = "";
  if (errorMsg) {
    errorClass = "has-error";
    errorMsg = errorMsg;
  }

  function handleChange(ev) {
    const {name, value} = ev.target;
    if (name == props.name) setQuery(value);
  }

  return (
    <>
      <div className={`dmpui-field-group  ${disabledClass}  ${errorClass}`}>
        <label className="dmpui-field-label">
          {props?.label ? props.label : ""}
        </label>
        <p className="dmpui-field-help">{props?.help ? props.help : ""}</p>

        {errorMsg && <p className="dmpui-field-error"> {errorMsg} </p>}

        <div className="dmpui-field-input-group">
          <input
            type="text"
            value={query}
            onChange={handleChange}
            name={props?.name ? props.name : "funder"}
            id={props?.id ? props.id : ""}
            placeholder={props?.placeholder}
            autoComplete={props?.autocomplete ? props.autocomplete : "off"}
            list="funder-lookup-results"
            className="dmpui-field-input-text"
          />

          <datalist id="funder-lookup-results">
            {query.length > 0 && suggestion?.map((el, index) => {
              return <option key={index} value={el.name} />;
            })}
          </datalist>
        </div>
      </div>
    </>
  );
}

export default FunderLookup;
