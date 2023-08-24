import {
  useState,
  useEffect,
} from "react";

function TextArea(props) {
  const [inputValue, setInputValue] = useState(props.inputValue);

  let disabledClass = props?.disabled ? "group-disabled" : "";
  let hiddenClass = props?.hidden ? "group-hidden" : "";

  useEffect(() => {
    setInputValue(props.inputValue)
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
      <div className={`dmpui-field-group ${disabledClass} ${hiddenClass} ${errorClass}`}>
        <label className="dmpui-field-label">
          {props?.label ? props.label : ""}
        </label>
        <p className="dmpui-field-help">{props?.help ? props.help : ""}</p>

        {errorMsg && <p className="dmpui-field-error"> {errorMsg} </p>}

        <div className="dmpui-field-input-group">
          <textarea
            value={inputValue}
            name={props?.name ? props.name : ""}
            id={props?.id ? props.id : ""}
            onChange={handleChange}
            placeholder={props?.placeholder}
            autoComplete={props?.autocomplete ? props.autocomplete : "off"}
            className="dmpui-field-input-textarea"
            disabled={props.disabled}
          >
          </textarea>
        </div>
      </div>
    </>
  );
}

export default TextArea;
