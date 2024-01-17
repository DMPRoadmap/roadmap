import { useState } from "react";


function RadioButton(props) {
  let errorMsg = props?.error ? props.error : "";
  let errorClass = "";
  if (errorMsg) {
    errorClass = "has-error";
    errorMsg = errorMsg;
  }

  function handleChange(ev) {
    if (props.onChange) props.onChange(ev);
  }

  return (
    <>
      <div className="dmpui-field-radio-group">
        <input
          type="radio"
          className="dmpui-field-input-radio"
          name={props?.name ? props.name : ""}
          id={props?.id ? props.id : ""}
          checked={props?.checked ? props.checked : ""}
          value={props?.inputValue ? props.inputValue : "x"}
          disabled={props.disabled}
          onChange={handleChange}
        />
        <label htmlFor={props?.id ? props.id : ""} className="radio-label">
          {props?.label ? props.label : ""}
        </label>
      </div>
    </>
  );
}

export default RadioButton;
