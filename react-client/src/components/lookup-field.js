import {
  useState,
  useEffect
} from "react";

import { DmpApi } from "../api.js";
import {getValue, useDebounce, isEmpty} from "../utils.js";


function LookupField(props) {
  const [query, setQuery] = useState(props.inputValue || "");
  const [suggestions, setSuggestions] = useState([]);
  const debounceQuery = useDebounce(query, 500);

  // Annoyingly, react components don't use the shadow dom, which mean
  // the ID's will be globally available instead of isolated within the
  // component. For this reason we'll use a simple random number for our
  // search lookup. We don't need somthing super random and secure, just
  // random enough not to clash with another search field.
  let resultsId = `lookupResults-${Math.floor(Math.random() * 1000)}`;

  let disabledClass = props?.disabled ? "group-disabled" : "";
  let errorMsg = props?.error ? props.error : "";

  var controller;

  useEffect(() => {
    setQuery(props.inputValue);
  }, [props.inputValue]);

  useEffect(() => {
    // NOTE: Since the server requires a limit of 3 characters,
    // we might as well avoid any work till we reach the minimum.
    if ((query.length > 2) && query !== props.inputValue) {
      if (controller) controller.abort();

      controller = new AbortController();

      let api = new DmpApi();
      let options = api.getOptions({signal: controller.signal});

      fetch(api.getPath(`/${props.endpoint}?search=${query}`), options)
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
    } else {
      setSuggestions(null);
    }

    // Cleanup the controller on component unmount
    return () => { if (controller) controller.abort(); };
  }, [debounceQuery]);


  let errorClass = "";
  if (errorMsg) {
    errorClass = "has-error";
    errorMsg = errorMsg;
  }

  function handleChange(ev) {
    const {name, value} = ev.target;
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
    }
    setQuery(value);
    props.onChange(ev);
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
            name={props?.name ? props.name : "lookup_query"}
            id={props?.id ? props.id : ""}
            placeholder={props?.placeholder}
            autoComplete={props?.autocomplete ? props.autocomplete : "off"}
            list={resultsId}
            className="dmpui-field-input-text"
            disabled={props.disabled}
          />

          <datalist id={resultsId}>
            {query.length > 0 && suggestions?.map((el, index) => {
              return <option data-index={index} value={el.name} />;
            })}
          </datalist>
        </div>
      </div>
    </>
  );
}

export default LookupField;
