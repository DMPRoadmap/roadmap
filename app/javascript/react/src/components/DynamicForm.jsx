import React, {
  useContext, useEffect, useState,
} from 'react';
import PropTypes from 'prop-types';
import toast from 'react-hot-toast';

import BuilderForm from './Builder/BuilderForm.jsx';
import { GlobalContext } from './context/Global.jsx';
import { checkRequiredForm, getLabelName, updateFormState } from '../utils/GeneratorUtils';
import { getFragment, saveForm } from '../services/DmpServiceApi';
import CustomSpinner from './Shared/CustomSpinner.jsx';
import CustomButton from './Styled/CustomButton.jsx';

function DynamicForm({
  fragmentId, dmpId, locale = 'en_GB',
}) {
  const {
    formData, setFormData, setlocale, setdmpId,
  } = useContext(GlobalContext);
  const [loading, setLoading] = useState(false);
  const [error] = useState(null);
  // eslint-disable-next-line global-require
  const [standardTemplate, setStandardTemplate] = useState(null);
  useEffect(() => {
    setLoading(true);
    setlocale(locale);
    setdmpId(dmpId);
    getFragment(fragmentId).then((res) => {
      setStandardTemplate(res.data.schema);
      setFormData({ [fragmentId]: res.data.fragment });
    }).catch(console.error)
      .finally(() => setLoading(false));
  }, [fragmentId]);

  /**
   * It checks if the form is filled in correctly.
   * @param e - the event object
   */
  const handleSaveForm = (e) => {
    e.preventDefault();
    const checkForm = checkRequiredForm(standardTemplate, formData[fragmentId]);
    if (checkForm) {
      toast.error(`Veuiller remplir le champ ${getLabelName(checkForm, standardTemplate, locale)}`);
    } else {
      setLoading(true);
      saveForm(fragmentId, formData[fragmentId]).then((res) => {
        setFormData({ [fragmentId]: res.data.fragment });
        toast.success(res.data.message);
      }).catch((res) => {
        toast.error(res.data.message);
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
        <div style={{ margin: '15px' }}>
          <div className="row"></div>
          <div className="m-4">
            <BuilderForm
              shemaObject={standardTemplate}
              level={1}
              fragmentId={fragmentId}
            ></BuilderForm>
          </div>
          <CustomButton handleNextStep={handleSaveForm} title="Enregistrer" position="center"></CustomButton>
        </div>
      )}
    </>
  );
}

DynamicForm.propTypes = {
  fragmentId: PropTypes.number,
  dmpId: PropTypes.number,
  locale: PropTypes.string,
};

export default DynamicForm;
