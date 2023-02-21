import { useContext, useState } from "react";
import { GlobalContext } from "../context/Global";

/* A React component that renders a form with a text input and a button. 
When the button is clicked, a new text input is added to the form. When the text
input is changed, the form is updated. */
function InputTextDynamicaly({ label, name, tooltip }) {
  const [formFields, setFormFields] = useState([""]);
  const { form, setform } = useContext(GlobalContext);

  /**
   * When the form changes, update the form fields and set the form to the new data.
   */
  const handleFormChange = (event, index) => {
    let data = [...formFields];
    data[index] = event.target.value;
    setFormFields(data);
    setform({ ...form, [name]: data });
  };

  /**
   * When the addFields function is called, the setFormFields function is called with the current formFields array and a new empty string.
   */
  const addFields = () => {
    setFormFields([...formFields, ""]);
  };

  /**
   * If the formFields array has more than one element, then remove the element at the index specified by the index parameter.
   */
  const removeFields = (index) => {
    if (formFields.length > 1) {
      let data = [...formFields];
      data.splice(index, 1);
      setFormFields(data);
      setform({ ...form, [name]: data });
    }
  };

  return (
    <div className="App">
      <label>{label}</label>
      {tooltip && (
        <span className="m-4" data-toggle="tooltip" data-placement="top" title={tooltip}>
          ?
        </span>
      )}

      {formFields.map((form, index) => {
        return (
          <div key={index}>
            <div className="row">
              <div className="col-9 mt-2">
                <input className="form-control" name={name} onChange={(event) => handleFormChange(event, index)} value={form.name} />
              </div>
              <div className="col-3">
                <button type="button" className="btn btn-primary px-3 m-2" onClick={addFields}>
                  <i className="fab fa-plus" aria-hidden="true" />
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
