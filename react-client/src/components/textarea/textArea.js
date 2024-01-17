import { useState, useEffect } from "react";

function TextArea(props) {
  const [inputValue, setInputValue] = useState(props.inputValue);

  let disabledClass = props?.disabled ? "group-disabled" : "";
  let hiddenClass = props?.hidden ? "group-hidden" : "";
  let requiredClass = props?.required ? "required" : "";

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
      <div className={`dmpui-field-group ${disabledClass} ${hiddenClass} ${errorClass} ${requiredClass}`}>
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
          <textarea
            required={props.required}
            value={inputValue}
            name={props?.name ? props.name : ""}
            id={props?.id ? props.id : ""}
            onChange={handleChange}
            placeholder={props?.placeholder}
            autoComplete={props?.autocomplete ? props.autocomplete : "off"}
            className="dmpui-field-input-textarea"
            disabled={props.disabled}
            {...(props.help && { "aria-describedby": `${props.id}-description` })}
          ></textarea>
        </div>
      </div>
    </>
  );
}

export default TextArea;
