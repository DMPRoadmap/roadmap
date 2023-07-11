import { useState, useMemo, useRef, useEffect } from "react";

import { DmpApi } from "../../api.js";

function FunderLookup(props) {
  const [inputType] = useState(props.type);

  const [query, setQuery] = useState("");
  // state that hold API data
  const [suggestion, setSuggestion] = useState([]);

  let disabledClass = props?.disabled ? "group-disabled" : "";

  let errorMsg = props?.error ? props.error : "";

  function debounce(func, wait, immediate) {
    var timeout;
    return function () {
      var context = this,
        args = arguments;
      var later = function () {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      var callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    };
  }

  const useDebounce = (callback) => {
    const ref = useRef();

    useEffect(() => {
      ref.current = callback;
    }, [callback]);

    const debouncedCallback = useMemo(() => {
      const func = () => {
        ref.current?.();
      };

      return debounce(func, 200);
    }, []);

    return debouncedCallback;
  };

  const getLocations = () => {
    console.log("query:" + query);

    if (!query) {
      console.log("query:" + empty);
      setSuggestion(null);
      return;
    }

    let api = new DmpApi();
    fetch(api.getPath(`/funders?search=${query}`))
      .then((resp) => {
        api.handleResponse(resp);
        return resp.json();
      })
      .then((data) => {
        console.log("data");
        console.log(data.items);
        setSuggestion(data.items);
      })
      .catch((err) => {
        if (err.response && err.response.status === 404) {
          setSuggestion(null);
        }
        errorMsg = err.response.toString();
      });
  };

  let errorClass = "";
  if (errorMsg) {
    errorClass = "has-error";
    errorMsg = errorMsg;
  }

  const onChange = () => {
    console.log("State value:", query);
    getLocations();
  };

  const debouncedOnChange = useDebounce(onChange);

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
            onChange={(e) => {
              setQuery(e.target.value);
              debouncedOnChange();
            }}
            name={props?.name ? props.name : ""}
            id={props?.id ? props.id : ""}
            placeholder={props?.placeholder}
            autoComplete={props?.autocomplete ? props.autocomplete : "off"}
            list="funder-lookup-results"
            className="dmpui-field-input-text"
          />

          <datalist id="funder-lookup-results">
            {query.length > 0 && // // required to avoid the dropdown list to display the locations fetched before
              suggestion?.map((el, index) => {
                return <option key={index} value={el.name} />;
              })}
          </datalist>
        </div>
      </div>
    </>
  );
}

export default FunderLookup;
