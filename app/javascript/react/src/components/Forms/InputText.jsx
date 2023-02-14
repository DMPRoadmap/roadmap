import React, { useContext, useEffect, useState } from "react";
import { getCheckPatern } from "../../utils/GeneratorUtils";
import { GlobalContext } from "../context/Global";

/**
 * It's a function that takes in a bunch of props and returns a div with a label, an input, and a small tag.
 * @returns A React Component
 */
function InputText({ label, type, placeholder, name, changeValue, tooltip, hidden, isConst }) {
  const { setform, temp } = useContext(GlobalContext);
  const [text, settext] = useState(null);
  const [isRequired, setisRequired] = useState(false);

  /* It's setting the state of the form to the value of the isConst variable. */
  useEffect(() => {
    if (isConst !== false) {
      setform({ [name]: isConst });
    }
  }, []);

  /**
   * It takes a number, formats it to a string, and then sets the state of the text variable to that string.
   * @param e - The event object
   */
  const handleChangeInput = (e) => {
    changeValue(e);
    //const formatedNumber = formatNumberWithSpaces(e.target.value);
    const isPattern = getCheckPatern(type, e.target.value);
    if (isPattern) {
      setisRequired(false);
    } else {
      setisRequired(true);
    }
    settext(e.target.value);
  };
  return (
    <div className="form-group">
      <label>{label}</label>
      {tooltip && (
        <span className="m-4" data-toggle="tooltip" data-placement="top" title={tooltip}>
          ?
        </span>
      )}

      <input
        // required={checkRequired(requiredList, name)}
        // pattern={checkPatern(type)}
        type={type}
        value={isConst === false ? (temp ? temp[name] : text == null ? "" : text) : isConst}
        className={isRequired ? "form-control outline-red" : "form-control"}
        hidden={hidden}
        placeholder={placeholder}
        onChange={handleChangeInput}
        name={name}
        disabled={isConst === false ? false : true}
      />
    </div>
  );
}

export default InputText;
