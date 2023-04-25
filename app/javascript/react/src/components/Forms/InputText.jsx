import React, { useContext, useEffect, useState } from 'react';
import { getCheckPattern } from '../../utils/GeneratorUtils';
import { GlobalContext } from '../context/Global.jsx';
import styles from "../assets/css/form.module.css";

/**
 * It's a function that takes in a bunch of props and returns
 * a div with a label, an input, and a small tag.
 * @returns A React Component
 */
function InputText({
  label, type, placeholder, propName, changeValue, tooltip, hidden, isConst, fragmentId
}) {
  const { formData, setFormData, subData } = useContext(GlobalContext);
  const [text, setText] = useState(null);
  const [isRequired, setisRequired] = useState(false);

  /* It's setting the state of the form to the value of the isConst variable. */
  useEffect(() => {
    if (isConst !== false) {
      setFormData({ [propName]: isConst });
    }
  }, []);

  useEffect(() => {
    setText(formData?.[fragmentId]?.[propName]);
  }, [propName[propName]]);

  /**
   * It takes a number, formats it to a string, and then sets the
   * state of the text variable to that string.
   * @param e - The event object
   */
  const handleChangeInput = (e) => {
    const { value } = e.target;
    const isPattern = getCheckPattern(type, value);
    changeValue(e);
    setisRequired(!isPattern);
    setText(value);
  };
  return (
    <div className="form-group">
      <div className={styles.label_form}>
        <strong className={styles.dot_label}></strong>
        <label>{label}</label>
        {tooltip && (
          <span className="" data-toggle="tooltip" data-placement="top" title={tooltip}>
            ?
          </span>
        )}
      </div>
      <input
        type={type}
        value={isConst === false ? (subData ? subData[propName] : text == null ? "" : text) : isConst}
        className={isRequired ? `form-control ${styles.input_text} ${styles.outline_red}` : `form-control ${styles.input_text}`}
        hidden={hidden}
        placeholder={placeholder}
        onChange={handleChangeInput}
        name={propName}
        disabled={isConst === false ? false : true}
      />
    </div>
  );
}

export default InputText;
