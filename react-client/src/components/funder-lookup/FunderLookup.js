import {
  useState,
  useEffect
} from "react";
import { DmpApi } from "../../api.js";


function FunderLookup(props) {
  const [query, setQuery] = useState(props.inputValue);
  const [suggestions, setSuggestions] = useState([]);

  let disabledClass = props?.disabled ? "group-disabled" : "";
  let errorMsg = props?.error ? props.error : "";

  var controller;

  useEffect(() => {
    if (controller) controller.abort();

    if (query == "") {
      setSuggestions(null);
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
        setSuggestions(data.items);
      })
      .catch((err) => {
        if (err.response && err.response.status === 404) {
          setSuggestions(null);
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

    if (name == props.name) {
      // NOTE: Check if the the change happend after selecting an option
      // in the datalist.
      // TODO:: I'm not sure if this specific check is handled the same
      // across browsers. We should test this one major browsers as well
      // as mobile devices to confirm.
      if (typeof ev.nativeEvent.inputType === "undefined") {
        let chosenEl = ev.target
                         .parentNode
                         .querySelector(`option[value="${value}"]`);
        let di = chosenEl.dataset["index"];
        ev.data = suggestions[di];
        props.onChange(ev);
      }
      setQuery(value);
    }
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
            list="funderLookupResults"
            className="dmpui-field-input-text"
            disabled={props.disabled}
          />

          <datalist id="funderLookupResults">
            {query.length > 0 && suggestions?.map((el, index) => {
              return <option data-index={index} value={el.name} />;
            })}
          </datalist>
        </div>
      </div>
    </>
  );
}

export default FunderLookup;
