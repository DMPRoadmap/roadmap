import { useState, useEffect } from "react";

function Select(props) {
  const [inputType] = useState(props.type);
  const [options, setOptions] = useState(props.options);
  const [inputValue, setInputValue] = useState(props.inputValue);

  useEffect(() => {
    setInputValue(props.inputValue);
  }, [props.inputValue]);

  function handleChange(ev) {
    setInputValue(ev.target.value);
    if (props.onChange) props.onChange(ev);
  }

  let errorMsg = props?.error ? props.error : "";
  let errorClass = "";
  if (errorMsg) {
    errorClass = "has-error";
    errorMsg = errorMsg;
  }

  return (
    <>
      <div className={"dmpui-field-group " + errorClass}>
        <label className="dmpui-field-label">
          {props?.label ? props.label : ""}
        </label>
        <p className="dmpui-field-help">{props?.help ? props.help : ""}</p>

        {errorMsg && <p className="dmpui-field-error"> {errorMsg} </p>}

        <div className="dmpui-field-input-group">
          <select
            type={inputType}
            value={inputValue}
            name={props?.name ? props.name : ""}
            id={props?.id ? props.id : ""}
            onChange={handleChange}
            autoComplete={props?.autocomplete ? props.autocomplete : "off"}
            className="dmpui-field-input-text select"
          >
            <option>Select one</option>
            {options &&
              Object.keys(options).map((key) => {
                return (
                  <option key={key} value={key}>
                    {options[key]}
                  </option>
                );
              })}
          </select>
        </div>
      </div>
    </>
  );
}

export default Select;
