import React, { useContext, useState } from 'react';
import { GlobalContext } from '../context/Global.jsx';
import { updateFormState } from '../../utils/GeneratorUtils';
import styles from '../assets/css/form.module.css';

/* A React component that renders a form with a text input and a button.
When the button is clicked, a new text input is added to the form. When the text
input is changed, the form is updated. */
function InputTextDynamicaly({ label, propName, tooltip, fragmentId }) {
  const [formFields, setFormFields] = useState(['']);
  const { formData, setFormData } = useContext(GlobalContext);
  
  /* A React hook that is called when the component is mounted and when the name variable changes. */
  useEffect(() => {
    setFormFields(form?.[fragmentId]?.[propName] || [""]);
  }, [propName]);

  /**
   * When the form changes, update the form fields and set the form to the new data.
   */
  const handleFormChange = (event, index) => {
    const data = [...formFields];
    data[index] = event.target.value;
    setFormFields(data);
    setFormData(updateFormState(formData, fragmentId, propName, data));
  };

  /**
   * When the addFields function is called, the setFormFields
   * function is called with the current formFields array and a new empty string.
   */
  const addFields = () => {
    setFormFields([...formFields, '']);
  };

  /**
   * If the formFields array has more than one element,
   * then remove the element at the index specified by the index parameter.
   */
  const removeFields = (index) => {
    if (formFields.length > 1) {
      const data = [...formFields];
      data.splice(index, 1);
      setFormFields(data);
      setform(updateFormState(formData, fragmentId, propName, data));
    }
  };

  return (
    <div className="App">
      <div className={styles.label_form}>
        <strong className={styles.dot_label}></strong>
        <label>{label}</label>
        {tooltip && (
          <span className="" data-toggle="tooltip" data-placement="top" title={tooltip}>
            ?
          </span>
        )}
      </div>
      {formFields.map((form, index) => {
        return (
          <div key={index} style={{ margin: "10px" }}>
            <div className="row">
              <div className="col-md-9">
                <input
                  className={`form-control ${styles.input_text}`}
                  value={form}
                  name={propName}
                  onChange={(event) => handleFormChange(event, index)}
                />
              </div>
              <div className="col-md-3">
                <button style={{ marginRight: "4px" }} type="button" className="btn btn-primary px-3 m-2" onClick={addFields}>
                  <i className="fa fa-plus" aria-hidden="true" />
                </button>
                <button type="button" className="btn btn-danger px-3 m-2" onClick={() => removeFields(index)}>
                  <i className="fa fa-trash" aria-hidden="true" />
                </button>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}

export default InputTextDynamicaly;
