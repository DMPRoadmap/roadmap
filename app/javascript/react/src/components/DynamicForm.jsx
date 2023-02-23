import React, { useContext, useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import toast from 'react-hot-toast';

// si type = string et inputtype = dropdown
import BuilderForm from './Builder/BuilderForm.jsx';
import { GlobalContext } from './context/Global.jsx';
import { checkRequiredForm, getLabelName } from '../utils/GeneratorUtils';
import { getFragment } from '../services/DmpServiceApi';

function DynamicForm({ fragmentId, dmpId, locale = 'en_GB', xsrf }) {
  const { form, setform, setlocale, setdmpId } = useContext(GlobalContext);
  // eslint-disable-next-line global-require
  const [standardTemplate, setStandardTemplate] = useState(null);
  useEffect(() => {
    setlocale(locale);
    setdmpId(dmpId);
    getFragment(fragmentId, xsrf).then((res) => {
      setStandardTemplate(res.data.schema);
      setform(res.data.fragment);
    }).catch(console.error);
  }, [fragmentId]);

  /**
   * It checks if the form is filled in correctly.
   * @param e - the event object
   */
  const handleSaveForm = (e) => {
    e.preventDefault();
    const checkForm = checkRequiredForm(standardTemplate, form);
    if (checkForm) {
      toast.error(`Veuiller remplir le champ ${getLabelName(checkForm, standardTemplate)}`);
    } else {
      console.log(form);
    }
  };

  return (
    <>
      <div className="col-10 m-4"></div>
      <div className="m-4">
        <BuilderForm shemaObject={standardTemplate} level={1} xsrf={xsrf}></BuilderForm>
      </div>
      <button onClick={handleSaveForm} className="btn btn-primary m-4">
        Enregistrer
      </button>
    </>
  );
}

DynamicForm.propTypes = {
  fragmentId: PropTypes.number,
  dmpId: PropTypes.number,
  schemaId: PropTypes.number,
  locale: PropTypes.string,
  xsrf: PropTypes.string,
};

export default DynamicForm;
