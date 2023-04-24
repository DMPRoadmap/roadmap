import React, { useContext } from 'react';
import PropTypes from 'prop-types';

import { GlobalContext } from '../context/Global.jsx';
import HandleGenerateForms from './HandleGenerateForms.jsx';
import { updateFormState } from '../../utils/GeneratorUtils.js';

function BuilderForm({ shemaObject, level, fragmentId }) {
  const {
    formData, setFormData, subData, setSubData,
  } = useContext(GlobalContext);

  /**
   * Object destructuring
   * If the level is 1, then set the form state to the value of the event target.
   *  If the level is not 1, then set the objectToAdd state to the value of the
   * event target.
   * @param event - the event that is triggered when the input is changed
   */
  const changeValue = (event) => {
    const { name, value } = event.target;
    if (level === 1) {
      const updatedFormData = { ...formData };
      updatedFormData[fragmentId] = updatedFormData[fragmentId] || {};
      updatedFormData[fragmentId][name] = value;
      setFormData(updatedFormData);
    } else {
      setSubData({ ...subData, [name]: { ...subData[name], ...value } });
    }
  };

  /**
   * It takes a JSON object and returns a React component
   * @returns An array of React components.
   */

  return (
    <HandleGenerateForms
      shemaObject={shemaObject}
      level={level}
      changeValue={changeValue}
      fragmentId={fragmentId}
    ></HandleGenerateForms>
  );
}

BuilderForm.propTypes = {
  fragmentId: PropTypes.number,
  shemaObject: PropTypes.object,
  level: PropTypes.number,
};

export default BuilderForm;
