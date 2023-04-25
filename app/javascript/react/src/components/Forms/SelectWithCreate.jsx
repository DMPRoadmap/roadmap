import React, { useContext, useEffect, useState } from 'react';
import Select from 'react-select';
import { Modal, Button } from 'react-bootstrap';
import Swal from 'sweetalert2';
import toast from 'react-hot-toast';
import { GlobalContext } from '../context/Global.jsx';
import {
  checkRequiredForm,
  createOptions,
  deleteByIndex,
  getLabelName,
  parsePattern,
  updateFormState,
} from '../../utils/GeneratorUtils';
import BuilderForm from '../Builder/BuilderForm.jsx';
import { getRegistry, getSchema } from '../../services/DmpServiceApi';
import styles from '../assets/css/form.module.css';

function SelectWithCreate({
  label,
  registryId,
  propName,
  templateId,
  level,
  tooltip,
  header,
  fragmentId,
}) {
  const [list, setlist] = useState([]);

  const [show, setShow] = useState(false);
  const [options, setOptions] = useState(null);
  const [selectObject, setselectObject] = useState([]);
  const {
    formData, setFormData, subData, setSubData, locale,
  } = useContext(GlobalContext);
  const [index, setindex] = useState(null);

  const [template, setTemplate] = useState(null);

  /* A hook that is called when the component is mounted.
  It is used to set the options of the select list. */
  useEffect(() => {
    getSchema(templateId).then((res) => {
      setTemplate(res.data);
      if (formData[propName]) {
        const pattern = res.data.to_string;
        if (pattern.length > 0) {
          Promise.all(
            formData?.[fragmentId]?.[propName].filter(
              (el) => el.action !== 'delete').map((el) => parsePattern(el, pattern))
            ).then((listParsed) => {
              setlist(listParsed);
            }
          );
        }
      }
    });
  }, [templateId, formData]);

  /* A hook that is called when the component is mounted.
  It is used to set the options of the select list. */
  useEffect(() => {
    let isMounted = true;
    if (isMounted) {
      getRegistry(registryId)
        .then((res) => {
          setOptions(createOptions(res.data, locale));
        })
        .catch((error) => {
          // handle errors
        });
      return () => {
        isMounted = false;
      };
    }
  }, [registryId, locale]);

  /**
   * It closes the modal and resets the state of the modal.
   */
  const handleClose = () => {
    setShow(false);
    setSubData({});
    setindex(null);
  };
  /**
   * The function takes a boolean value as an argument and sets the state of the show variable to the value of the argument.
   * @param isOpen - boolean
   */
  const handleShow = (e) => {
    e.stopPropagation();
    e.preventDefault();
    setShow(true);
  };

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleChangeList = (e) => {
    const pattern = template.to_string;
    const parsedPattern = pattern.length > 0 ? parsePattern(e.object, pattern) : null;
    const updatedList = pattern.length > 0 ? [...list, parsedPattern] : [...list, e.value];
    setlist(updatedList);
    setselectObject(
      pattern.length > 0 ? [...selectObject, e.object] : selectObject,
    );
    setFormData(updateFormState(formData, fragmentId, propName, [...(formData[fragmentId]?.[propName] || []), e.object]));
  };

  /**
   * It creates a new array, then removes the item at the index specified by the parameter,
   * then sets the state to the new array.
   * @param idx - the index of the item in the array
   */
  const handleDeleteList = (e, idx) => {
    e.preventDefault();
    e.stopPropagation();
    Swal.fire({
      title: 'Ëtes-vous sûr ?',
      text: 'Voulez-vous vraiment supprimer cet élément ?',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#3085d6',
      cancelButtonColor: '#d33',
      cancelButtonText: 'Annuler',
      cancelButtonText: 'Annuler',
      confirmButtonText: 'Oui, supprimer !',
    }).then((result) => {
      if (result.isConfirmed) {
        const newList = [...list];
        setlist(deleteByIndex(newList, idx));
        const concatedObject = [...formData[fragmentId][propName]];
        concatedObject[idx]['action'] = 'delete';
        setFormData(updateFormState(formData, fragmentId, propName, concatedObject));
        Swal.fire('Supprimé!', 'Opération effectuée avec succès!.', 'success');
      }
    });
  };

  /**
   * If the index is not null, then delete the item at the index,
   * add the subData item to the end of the array,
   * and then splice the item from the list array.
   * If the index is null, then just save the item.
   */
  const handleAddToList = () => {
    if (!subData) {
      handleClose();
      return;
    }

    const checkForm = checkRequiredForm(template, subData);
    if (checkForm) {
      toast.error(
        `Veuiller remplire le champs ${getLabelName(checkForm, template)}`,
      );
    } else {
      if (index !== null) {
        //add in update
        const filterDeleted = formData?.[fragmentId]?.[propName].filter((el) => el.action !== 'delete');
        const deleteIndex = deleteByIndex(filterDeleted, index);
        const concatedObject = [...deleteIndex, { ...subData, action: 'update' }];
        setFormData(updateFormState(formData, fragmentId, propName, concatedObject));

        const newList = deleteByIndex([...list], index);
        const parsedPattern = parsePattern(subData, template.to_string);
        const copieList = [...newList, parsedPattern];
        setlist(copieList);
        setSubData({});
        handleClose();
      } else {
        handleSave();
      }
      toast.success('Enregistrement a été effectué avec succès !');
    }
  };

  /**
   * I'm trying to add a new object to an array of objects, and then add that array to a new object.
   */
  const handleSave = () => {
    let newObject = formData[fragmentId][propName] ? [...formData[fragmentId][propName], subData] : [subData];
    setFormData(updateFormState(formData, fragmentId, propName, newObject));
    setlist([...list, parsePattern(subData, template.to_string)]);
    handleClose();
    setSubData({});
  };

  /**
   * It sets the state of the subData variable to the value of the formData[propName][idx] variable.
   * @param idx - the index of the item in the array
   */
  const handleEdit = (idx) => {
    e.preventDefault();
    e.stopPropagation();
    const filterDeleted = formData?.[fragmentId]?.[propName].filter((el) => el.action !== 'delete');
    setSubData(filterDeleted[idx]);
    setShow(true);
    setindex(idx);
  };

  return (
    <>
      <fieldset className="sub-fragment registry">
        <legend className="sub-fragment" data-toggle="tooltip" data-original-title={tooltip}>
          <strong className={styles.dot_label}></strong>
          {label}
        </legend>
        <div className={styles.input_label}>Sélectionnez une valeur de la liste.</div>
        <div className="row col-md-12">
          <div className={`col-md-11 ${styles.select_wrapper}`}>
            <Select
              menuPortalTarget={document.body}
              styles={{ menuPortal: (base) => ({ ...base, zIndex: 9999 }) }}
              onChange={handleChangeList}
              options={options}
              name={propName}
              defaultValue={{
                label: subData ? subData[propName] : '',
                value: subData ? subData[propName] : '',
              }}
            />
          </div>
          <div className="col-md-1" style={{ marginTop: "8px" }}>
            <span>
              <a className="text-primary" href="#" onClick={(e) => handleShow(e)}>
                <i className="fas fa-plus-square" />
              </a>
            </span>
          </div>
        </div>
        {list && (
          <table style={{ marginTop: "20px" }} className="table table-bordered">
            <thead>
              {formData?.[fragmentId]?.[propName]?.length > 0 && header && (
                <tr>
                  <th scope="col">{header}</th>
                  <th scope="col"></th>
                </tr>
              )}
            </thead>
            <tbody>
              {list.map((el, idx) => (
                <tr key={idx}>
                  <td scope="row">
                    <p className={`m-2 ${styles.border}`}> {el} </p>
                  </td>
                  <td style={{ width: "10%" }}>
                    <div className="col-md-1" style={{ marginTop: "8px" }}>
                      {level === 1 && (
                        <span>
                          <a className="text-primary" href="#" aria-hidden="true" onClick={(e) => handleEdit(e, idx)}>
                            <i className="fa fa-edit" />
                          </a>
                        </span>
                      )}
                    </div>
                    <div className="col-md-1" style={{ marginTop: "8px" }}>
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
      </fieldset>
      <>
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
    </>
  );
}

export default SelectWithCreate;
