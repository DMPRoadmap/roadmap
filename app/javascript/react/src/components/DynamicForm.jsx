import React, { useContext, useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import toast from 'react-hot-toast';

// si type = string et inputtype = dropdown
import BuilderForm from './Builder/BuilderForm.jsx';
import { GlobalContext } from './context/Global.jsx';
import { checkRequiredForm, getLabelName } from '../utils/GeneratorUtils';
import { getFragment, saveForm } from '../services/DmpServiceApi';
import CustomSpinner from './Shared/CustomSpinner.jsx';

function DynamicForm({ fragmentId, dmpId, locale = 'en_GB' }) {
  const { formData, setFormData, setlocale, setdmpId } = useContext(GlobalContext);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  // eslint-disable-next-line global-require
  const [standardTemplate, setStandardTemplate] = useState(null);
  useEffect(() => {
    setLoading(true);
    setlocale(locale);
    setdmpId(dmpId);
    getFragment(fragmentId).then((res) => {
      setStandardTemplate(res.data.schema);
      setFormData(res.data.fragment);
    }).catch(console.error)
      .finally(() => setLoading(false));
  }, [fragmentId]);

  /**
   * It checks if the form is filled in correctly.
   * @param e - the event object
   */
  const handleSaveForm = (e) => {
    e.preventDefault();
    setLoading(true);
    const checkForm = checkRequiredForm(standardTemplate, formData);
    if (checkForm) {
      toast.error(`Veuiller remplir le champ ${getLabelName(checkForm, standardTemplate, locale)}`);
    } else {
      saveForm(fragmentId, formData).then((res) => {
        toast.success(res.data.message);
      }).catch((error) => {
        toast.success(error.data.message);
      })
        .finally(() => setLoading(false));
    }
  };

  return (
    <>
      {loading && (
        <div className="overlay">
          <CustomSpinner></CustomSpinner>
        </div>
      )}
      {!loading && error && <p>error</p>}
      {!loading && !error && standardTemplate && (
        <div className="m-4">
          <BuilderForm shemaObject={standardTemplate} level={1}></BuilderForm>
          <button onClick={handleSaveForm} className="btn btn-primary m-4">
            Enregistrer
          </button>
        </div>
      )}
    </>
  );
}

DynamicForm.propTypes = {
  fragmentId: PropTypes.number,
  dmpId: PropTypes.number,
  schemaId: PropTypes.number,
  locale: PropTypes.string,
};

export default DynamicForm;
