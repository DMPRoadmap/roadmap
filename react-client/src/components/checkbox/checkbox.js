import { useState } from "react";

function Checkbox({ isChecked,
                    error,
                    id,
                    name,
                    label,
                    inputValue,
                    onChange,
                    disabled
                  }) {
  const [checked, setChecked] = useState(isChecked ? isChecked : false);

  let errorMsg = error ? error : "";
  let errorClass = "";
  if (errorMsg) {
    errorClass = "has-error";
    errorMsg = errorMsg;
  }

  function handleChange(ev) {
    const { name, value, chk } = ev.target;
    setChecked(chk);
    if (onChange) onChange(ev);
  }

  return (
    <>
      <div className="dmpui-field-checkbox-group">
        <input
          type="checkbox"
          className="dmpui-field-input-checkbox"
          name={name ? name : ""}
          id={id ? id : ""}
          checked={isChecked}
          onChange={handleChange}
          value={inputValue}
          disabled={disabled}
        />
        <label htmlFor={id ? id : ""} className="checkbox-label">
          {label ? label : ""}
        </label>
      </div>
      {errorMsg && <p className="dmpui-field-error"> {errorMsg} </p>}
    </>
  );
}

export default Checkbox;
