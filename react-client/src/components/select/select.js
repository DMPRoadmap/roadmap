import { useState, useEffect } from "react";

function Select(props) {
  function handleChange(ev) {
    if (props.onChange) props.onChange(ev);
  }

  let errorMsg = props?.error ? props.error : "";
  let errorClass = "";
  if (errorMsg) {
    errorClass = " has-error ";
    errorMsg = errorMsg;
  }

  let requiredClass = props?.required ? " required " : "";

  return (
    <>
      <div className={"dmpui-field-group " + errorClass + requiredClass}>
        <label className="dmpui-field-label">
          {props?.label ? props.label : ""}
        </label>
        <p className="dmpui-field-help">{props?.help ? props.help : ""}</p>

        {errorMsg && <p className="dmpui-field-error"> {errorMsg} </p>}

        <div className="dmpui-field-input-group">
          <select
            name={props?.name ? props.name : ""}
            value={props?.inputValue ? props.inputValue : ""}
            onChange={handleChange}
            autoComplete={props?.autocomplete ? props.autocomplete : "off"}
            className="dmpui-field-input-text select"
          >
            {props.emptyText && (
              <option value="">{props.emptyText}</option>
            )}

            {props.options &&
              Object.keys(props.options).map((key) => {
                return (
                  <option key={key} value={key}>
                    {props.options[key]}
                  </option>
                );
              })
            }
          </select>
        </div>
      </div>
    </>
  );
}

export default Select;
