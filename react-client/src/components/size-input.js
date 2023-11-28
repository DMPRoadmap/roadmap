import { useState, useEffect } from "react";
import Select from "./select/select.js";


function SizeInput(props) {
  const [unitOptions, setUnitOptions] = useState(props.unitOptions);
  const [sizeValue, setSizeValue] = useState(props.initialValue);
  const [sizeUnit, setSizeUnit] = useState(props.initialUnit);

  let disabledClass = props?.disabled ? "group-disabled" : "";
  let hiddenClass = props?.hidden ? "group-hidden" : "";
  let requiredClass = props?.required ? "required" : "";

  useEffect(() => {
    if (typeof props.initialUnit === "undefined") {
      setSizeUnit(Object.keys(props.unitOptions)[0]);
    } else {
      setSizeUnit(props.initialUnit);
    }

    if (typeof props.initialValue === "undefined") {
      setSizeValue(0);
    } else {
      setSizeValue(props.initialValue);
    }
  }, [props.unitOptions]);


  useEffect(() => {
    props.onChange({
      value: parseInt(sizeValue, 10),
      unit: sizeUnit,
    });
  }, [sizeValue, sizeUnit])


  function handleChange(ev) {
    const { name, value } = ev.target;
    switch (name) {
      case "size_value":
        setSizeValue(value);
        break;

      case "size_unit":
        setSizeUnit(value);
        break;
    }
  }


  let errorMsg = props?.error ? props.error : "";
  let errorClass = "";
  if (errorMsg) {
    errorClass = "has-error";
    errorMsg = errorMsg;
  }


  return (
    <>
      <div
        className={`dmpui-field-group ${disabledClass} ${hiddenClass} ${errorClass} ${requiredClass}`}
      >
        <label
          className="dmpui-field-label"
          htmlFor={props?.id ? props.id : ""}
        >
          {props?.label ? props.label : ""}
        </label>
        <p className="dmpui-field-help">{props?.help ? props.help : ""}</p>

        {errorMsg && <p className="dmpui-field-error"> {errorMsg} </p>}

        <div className="dmpui-field-row">
          <input
            required={props.required}
            type="number"
            value={sizeValue}
            name="size_value"
            onChange={handleChange}
            placeholder={props?.placeholder}
            autoComplete="off"
            className="dmpui-field-input-text"
            disabled={props.disabled}
          />

          <Select
            options={unitOptions}
            name="size_unit"
            inputValue={sizeUnit}
            onChange={handleChange}
          />
        </div>
      </div>
    </>
  );
}


export default SizeInput;
