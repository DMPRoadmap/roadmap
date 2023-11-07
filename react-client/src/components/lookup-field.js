import { useState, useEffect } from "react";

import { DmpApi } from "../api.js";
import { useDebounce } from "../utils.js";
import Spinner from "./spinner.js";


function LookupField(props) {
  const [suggestions, setSuggestions] = useState([]);
  const [showSuggestionSpinner, setShowSuggestionSpinner] = useState(false);
  const debounceQuery = useDebounce(props.inputValue, 500);

  // Annoyingly, react components don't use the shadow dom, which mean
  // the ID's will be globally available instead of isolated within the
  // component. For this reason we'll use a simple random number for our
  // search lookup. We don't need somthing super random and secure, just
  // random enough not to clash with another search field.
  let resultsId = `lookupResults-${Math.floor(Math.random() * 1000)}`;

  let disabledClass = props?.disabled ? "group-disabled" : "";
  let requiredClass = props?.required ? "required" : "";
  let errorMsg = props?.error ? props.error : "";

  var controller;

  useEffect(() => {
    // NOTE: Since the server requires a limit of 3 characters,
    // we might as well avoid any work till we reach the minimum.
    if (props.inputValue.length > 2) {
      setShowSuggestionSpinner(true);
      if (controller) controller.abort();

      controller = new AbortController();

      let api = new DmpApi();
      let options = api.getOptions({ signal: controller.signal });

      fetch(
        api.getPath(`/${props.endpoint}?search=${props.inputValue}`),
        options
      )
        .then((resp) => {
          api.handleResponse(resp);
          return resp.json();
        })
        .then((data) => {
          setSuggestions(data.items);
          setShowSuggestionSpinner(false);
        })
        .catch((err) => {
          if (err.response && err.response.status === 404) {
            setSuggestions(null);
            setShowSuggestionSpinner(false);
          } else {
            console.log('Api error:');
            console.log(err.response);
          }
        });
    } else {
      setSuggestions(null);
      setShowSuggestionSpinner(false);
    }

    // Cleanup the controller on component unmount
    return () => {
      if (controller) controller.abort();
    };
  }, [debounceQuery]);

  let errorClass = "";
  if (errorMsg) {
    errorClass = "has-error";
    errorMsg = errorMsg;
  }


  function handleChange(ev) {
    const { name, value } = ev.target;
    document.querySelectorAll(`#${resultsId} option`).forEach(el => {
      if (el.value === value) {
        let index = el.dataset['index'];
        ev.data = suggestions[index];
      }
    });
    props.onChange(ev);
  }

  return (
    <>
      <div className={`dmpui-field-group ${disabledClass} ${errorClass} ${requiredClass}`}>
        <label
          className="dmpui-field-label"
          htmlFor={props?.id ? props.id : ""}
        >
          {props?.label ? props.label : ""}
        </label>
        <p
          className="dmpui-field-help"
          id={props?.id ? props.id + "-description" : ""}
        >
          {props?.help ? props.help : ""}
        </p>

        {errorMsg && <p className="dmpui-field-error"> {errorMsg} </p>}

        <div className="dmpui-field-input-group">
          <div className="dmpui-field-input-lookup-icon-wrapper">
            <input
              type="text"
              onChange={handleChange}
              value={props.inputValue}
              name={props?.name ? props.name : "lookup_query"}
              id={props?.id ? props.id : ""}
              placeholder={props?.placeholder}
              autoComplete={props?.autocomplete ? props.autocomplete : "off"}
              list={resultsId}
              className={`dmpui-field-input-text ${showSuggestionSpinner ? "show-spinner" : ""
                }`}
              disabled={props.disabled}
              {...(props.help && { "aria-describedby": `${props.id}-description` })}


            />
            <Spinner className="dmpui-field-input-spinner"
              message="Searching…"
              isActive={showSuggestionSpinner} />
          </div>
          <datalist id={resultsId}>
            {props.inputValue.length > 0 && suggestions?.map((el, index) => {
              return <option key={index} data-index={index} value={el.name} />
            })}
          </datalist>
        </div>
      </div>
    </>
  );
}

export default LookupField;
