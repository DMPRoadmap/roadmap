import { useState } from "react";

function Checkbox(props) {
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
      <div className="dmpui-field-checkbox-group">
        <input
          type="checkbox"
          className="dmpui-field-input-checkbox"
          name={props?.name ? props.name : ""}
          id={props?.id ? props.id : ""}
          checked={props?.checked ? props.checked : ""}
          value={props?.inputValue ? props.inputValue : "x"}
          disabled={props.disabled}
          onChange={handleChange}
        />
        <label htmlFor={props?.id ? props.id : ""} className="checkbox-label">
          {props?.label ? props.label : ""}
        </label>
      </div>
    </>
  );
}

export default Checkbox;
