import React, { useContext, useEffect, useState } from 'react';
import { Modal, Button } from 'react-bootstrap';
import Swal from 'sweetalert2';
import toast from 'react-hot-toast';

import BuilderForm from '../Builder/BuilderForm.jsx';
import { GlobalContext } from '../context/Global.jsx';
import {
  checkRequiredForm,
  createMarkup,
  deleteByIndex,
  getLabelName,
  updateFormState,
  parsePattern,
} from '../../utils/GeneratorUtils';
import { getSchema } from '../../services/DmpServiceApi';
import CustomButton from '../Styled/CustomButton.jsx';
import styles from '../assets/css/form.module.css';

/**
 * It takes a template name as an argument, loads the template file, and then
 * renders a modal with the template file as a prop.
 * </code>
 * @returns A React component.
 */
function ModalTemplate({
  propName,
  value,
  templateId,
  level,
  tooltip,
  header,
  fragmentId,
}) {
  const [show, setShow] = useState(false);
  const { formData, setFormData, subData, setSubData, locale } = useContext(GlobalContext);
  const [index, setindex] = useState(null);

  const [template, setTemplate] = useState(null);
  useEffect(() => {
    getSchema(templateId).then((res) => {
      setTemplate(res.data);
    });
  }, [templateId]);
  /**
   * The function sets the show state to false
   */
  const handleClose = () => {
    setShow(false);
    setSubData({});
    setindex(null);
  };

  /**
   * If the subData variable is not empty, check if the form is valid, if it is,
   * add the subData variable to the form, if it's not, show an error message.
   */
  const handleAddToList = () => {
    if (!subData) return handleClose();

    const checkForm = checkRequiredForm(template, subData);
    if (checkForm)
      return toast.error(
        `Veuiller remplir le champs ${getLabelName(checkForm, template)}`
      );

    if (index !== null) {
      const filterDeleted = formData?.[fragmentId]?.[propName].filter((el) => el.action !== 'delete');
      const deleteIndex = deleteByIndex(filterDeleted, index);
      const concatedObject = [...deleteIndex, { ...subData, action: 'update' }];
      setFormData(updateFormState(formData, fragmentId, propName, concatedObject));
      setSubData({});
    } else {
      handleSave();
      toast.success('Enregistrement a été effectué avec succès !');
    }
    handleClose();
  };

  /**
   * When the user clicks the save button, the form is updated with the new data,
   * the subData is set to null, and the modal is closed.
   */
  const handleSave = () => {
    const newObject = [...(formData[fragmentId][propName] || []), { ...subData, action: 'create' }];
    setFormData(updateFormState(formData, fragmentId, propName, newObject));
    setSubData({});
    handleClose();
  };

  /**
   * The function takes a boolean value as an argument and sets the state
   * of the show variable to the value of the argument.
   * @param isOpen - boolean
   */
  const handleShow = (isOpen) => {
    setShow(isOpen);
  };

  /**
   * It creates a new array, then removes the item at the index specified
   * by the parameter, then sets the state to the new array.
   * @param idx - the index of the item in the array
   */
  const handleDeleteList = (e, idx) => {
    e.preventDefault();
    e.stopPropagation();
    Swal.fire({
      title: 'Ëtes-vous sûr ?',
      text: 'Voulez-vous vraiment supprimer cet élément ?',
      showCancelButton: true,
      confirmButtonColor: '#3085d6',
      cancelButtonColor: '#d33',
      cancelButtonText: 'Annuler',
      confirmButtonText: 'Oui, supprimer !',
    }).then((result) => {
      if (result.isConfirmed) {
        const filterDeleted = formData?.[fragmentId]?.[propName].filter((el) => el.action !== 'delete');
        filterDeleted[idx]['action'] = 'delete';
        setFormData(updateFormState(formData, fragmentId, propName, filterDeleted));
      }
    });
  };

  /**
   * This function handles the edit functionality for a form element in a React component.
   */
  const handleEdit = (e, idx) => {
    e.preventDefault();
    e.stopPropagation();
    const filterDeleted = formData?.[fragmentId]?.[propName].filter((el) => el.action !== 'delete');
    setSubData(filterDeleted[idx]);
    setShow(true);
    setindex(idx);
  };

  return (
    <>
      <fieldset className="sub-fragment border p-2 mb-2">
        <legend className="sub-fragment" data-toggle="tooltip" data-original-title={tooltip}>
          {value[`form_label@${locale}`]}
        </legend>
        {formData?.[fragmentId]?.[propName] && template && (
          <table style={{ marginTop: '20px' }} className="table table-bordered">
            <thead>
              {formData?.[fragmentId]?.[propName].length > 0 &&
                template &&
                header &&
                formData?.[fragmentId]?.[propName].some((el) => el.action !== 'delete') && (
                  <tr>
                    <th scope="col">{header}</th>
                    <th scope="col"></th>
                  </tr>
                )}
            </thead>
            <tbody>
              {formData?.[fragmentId]?.[propName]
                .filter((el) => el.action !== 'delete')
                .map((el, idx) => (
                  <tr key={idx}>
                    <td scope="row">
                      <div className={styles.border} dangerouslySetInnerHTML={createMarkup(parsePattern(el, template.to_string))}></div>
                    </td>
                    <td style={{ width: "10%" }}>
                      <div className="col-md-1">
                        {level === 1 && (
                          <span>
                            <a className="text-primary" href="#" aria-hidden="true" onClick={(e) => handleEdit(e, idx)}>
                              <i className="fa fa-edit" />
                            </a>
                          </span>
                        )}
                      </div>
                      <div className="col-md-1">
                        <span>
                          <a className="text-primary" href="#" aria-hidden="true" onClick={(e) => handleDeleteList(e, idx)}>
                            <i className="fa fa-times" />
                          </a>
                        </span>
                      </div>
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        )}
        <CustomButton
          handleNextStep={() => {
            handleShow(true);
          }}
          title="Ajouter un élément"
          type="primary"
          position="start"
        ></CustomButton>
      </fieldset>
      <Modal show={show} onHide={handleClose}>
        <Modal.Body>
          <BuilderForm
            shemaObject={template}
            level={level + 1}
            fragmentId={fragmentId}
          ></BuilderForm>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleClose}>
            Fermer
          </Button>
          <Button variant="primary" onClick={handleAddToList}>
            Enregistrer
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  );
}

export default ModalTemplate;
