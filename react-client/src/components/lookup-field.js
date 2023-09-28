import { useState, useEffect } from "react";

import { DmpApi } from "../api.js";
import { useDebounce } from "../utils.js";

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
  let errorMsg = props?.error ? props.error : "";

  var controller;

  useEffect(() => {
    // NOTE: Since the server requires a limit of 3 characters,
    // we might as well avoid any work till we reach the minimum.
    setShowSuggestionSpinner(true);
    if (props.inputValue.length > 2) {
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
          }
          errorMsg = err.response.toString();
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
    ev.preventDefault();
    const { name, value } = ev.target;

    // NOTE: Check if the the change happend after selecting an option
    // in the datalist.
    // TODO:: I'm not sure if this specific check is handled the same
    // across browsers. We should test this one major browsers as well
    // as mobile devices to confirm.
    if (typeof ev.nativeEvent.inputType === "undefined") {
      let el = document.querySelector(`#${resultsId} option[value="${value}"]`);
      let index = el.dataset['index'];
      ev.data = suggestions[index];
    }

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
          <div className="dmpui-field-input-lookup-icon-wrapper">
            <input
              type="text"
              value={props.inputValue}
              onChange={handleChange}
              name={props?.name ? props.name : "lookup_query"}
              id={props?.id ? props.id : ""}
              placeholder={props?.placeholder}
              autoComplete={props?.autocomplete ? props.autocomplete : "off"}
              list={resultsId}
              className={`dmpui-field-input-text ${
                showSuggestionSpinner ? "show-spinner" : ""
              }`}
              disabled={props.disabled}
            />
            {showSuggestionSpinner && (
              <div className="dmpui-field-input-spinner">
                <svg
                  id="loading-spinner"
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 48 48"
                >
                  <g fill="none">
                    <path
                      id="track"
                      fill="#C6CCD2"
                      d="M24,48 C10.745166,48 0,37.254834 0,24 C0,10.745166 10.745166,0 24,0 C37.254834,0 48,10.745166 48,24 C48,37.254834 37.254834,48 24,48 Z M24,44 C35.045695,44 44,35.045695 44,24 C44,12.954305 35.045695,4 24,4 C12.954305,4 4,12.954305 4,24 C4,35.045695 12.954305,44 24,44 Z"
                    />
                    <path
                      id="section"
                      fill="#3F4850"
                      d="M24,0 C37.254834,0 48,10.745166 48,24 L44,24 C44,12.954305 35.045695,4 24,4 L24,0 Z"
                    />
                  </g>
                </svg>
              </div>
            )}
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
