import React, { useContext, useEffect, useState } from 'react';
import { Modal, Button } from 'react-bootstrap';
import Select from 'react-select';
import Swal from 'sweetalert2';
import toast from 'react-hot-toast';
import BuilderForm from '../Builder/BuilderForm.jsx';
import { deleteByIndex, parsePattern, updateFormState } from '../../utils/GeneratorUtils';
import { GlobalContext } from '../context/Global.jsx';
import { getContributors, getSchema } from '../../services/DmpServiceApi';
import styles from '../assets/css/form.module.css';

function SelectContributor({
  label,
  propName,
  changeValue,
  templateId,
  level,
  tooltip,
  header,
  fragmentId,
}) {
  const [list, setList] = useState([]);

  const [show, setShow] = useState(false);
  const [options, setOptions] = useState(null);
  const [selectObject, setSelectObject] = useState([]);
  const {
    formData, setFormData, subData, setSubData, locale, dmpId,
  } = useContext(GlobalContext);
  const [index, setIndex] = useState(null);
  const [template, setTemplate] = useState(null);
  const [role, setRole] = useState(null);
  const [contributorList, setContributorList] = useState([])

  useEffect(() => {
    setContributorList(formData?.[fragmentId]?.[propName] || {})
  }, [fragmentId, propName]);

  /* A hook that is called when the component is mounted. */
  useEffect(() => {
    getContributors(dmpId, templateId).then((res) => {
      const builtOptions = res.data.results.map((option) => ({
        value: option.id,
        label: option.text,
        object: option,
      }));
      setOptions(builtOptions);
    });
  }, []);

  /* A hook that is called when the component is mounted. */
  useEffect(() => {
    getSchema(templateId).then((res) => {
      setRole(res.properties.role[`const@${locale}`]);
      const personTemplateId = res.properties.person.schema_id;
      setTemplate(personTemplateId);
      getSchema(personTemplateId).then((resSchema) => {
        setTemplate(resSchema.data);
      });

      if (!contributorList) {
        return;
      }
      const pattern = res.to_string;
      if (!pattern.length) {
        return;
      }

      setList(contributorList.filter((el) => el.action !== 'delete').map((el) => parsePattern(el, patern)));
    });
  }, [formData[propName], templateId]);

  /**
   * It closes the modal and resets the state of the modal.
   */
  const handleClose = () => {
    setShow(false);
    setSubData({});
    setIndex(null);
  };
  /**
   * The function takes a boolean value as an argument and sets the state of
   * the show variable to the value of the argument.
   * @param isOpen - boolean
   */
  const handleShow = (isOpen) => {
    setShow(isOpen);
  };

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleChangeList = (e) => {
    const pattern = template.to_string;
    const { object, value } = e;

    if (pattern.length > 0) {
      setSelectObject([...selectObject, object]);
      const parsedPatern = parsePattern(object, template.to_string);
      setList([...list, parsedPatern]);
      const newObject = { person: object, role: role };
      const mergedList = contributorList ? [...contributorList, newObject] : [newObject];
      setFormData(updateFormState(formData, fragmentId, propName, mergedList));
    } else {
      changeValue({ target: { propName, value } });
      setList([...list, value]);
    }
  };

  /**
   * If the index is not null, then delete the item at the index,
   * add the subData item to the end of the array,
   * and then splice the item from the list array.
   * If the index is null, then just save the item.
   */
  const handleAddToList = () => {
    if (index !== null) {
      const objectPerson = { person: subData, role: role, action: 'update' };
      const filterDeleted = contributorList.filter((el) => el.action !== 'delete');
      const deleteIndex = deleteByIndex(filterDeleted, index);
      const concatedObject = [...deleteIndex, objectPerson];
      setFormData(updateFormState(formData, fragmentId, propName, concatedObject));
      const parsedPattern = parsePattern(subData, template.to_string);
      setList([...deleteByIndex([...list], index), parsedPattern]);
    } else {
      handleSave();
    }
    toast.success('Enregistrement a été effectué avec succès !');
    setSubData({});
    handleClose();
  };

  /**
   * When the user clicks the save button, the function will take the
   * temporary person object and add it to the form object, then it will parse the
   * temporary person object and add it to the list array, then it will close the
   * modal and set the temporary person object to null.
   */
  const handleSave = () => {
    const objectPerson = { person: subData, role };
    setFormData(updateFormState(formData, fragmentId, propName, [...(contributorList || []), objectPerson]));
    const parsedPattern = parsePattern(subData, template.to_string);
    setList([...list, parsedPattern]);
    handleClose();
    setSubData({});
  };

  /**
   * I want to delete an item from a list and then update the state of the list.
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
      confirmButtonText: 'Oui, supprimer !',
    }).then((result) => {
      if (result.isConfirmed) {
        const newList = [...list];
        setList(deleteByIndex(newList, idx));
        const filterDeleted = contributorList.filter((el) => el.action !== 'delete');
        filterDeleted[idx]['action'] = 'delete';
        setFormData(updateFormState(formData, fragmentId, propName, filterDeleted));
      }
    });
  };

  /**
   * It sets the state of the subData variable to the value of the form[propName][idx] variable.
   * @param idx - the index of the item in the array
   */
  const handleEdit = (e, idx) => {
    e.preventDefault();
    e.stopPropagation();
    const filterDeleted = contributorList.filter((el) => el.action !== 'delete');
    setSubData(filterDeleted[idx]['person']);
    setShow(true);
    setIndex(idx);
  };

  return (
    <>
      <div className="form-group">
        <div className={styles.label_form}>
          <strong className={styles.dot_label}></strong>
          <label>{label}</label>
          {tooltip && (
            <span className="m-4" data-toggle="tooltip" data-placement="top" title={tooltip}>
              ?
            </span>
          )}
        </div>
        <div className={styles.input_label}>Sélectionnez une valeur de la liste.</div>
        <div className="row">
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
          <div className="col-md-2" style={{ marginTop: '8px' }}>
            <span>
              <a className="text-primary" href="#" aria-hidden="true" onClick={(e) => handleShow(e)}>
                <i className="fas fa-plus-square" />
              </a>
            </span>
          </div>
        </div>
        {contributorList && list && (
          <table style={{ marginTop: '20px' }} className="table table-bordered">
            <thead>
              {contributorList.length > 0 && header && contributorList.some((el) => el.action !== "delete") && (
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
                    <p className={`m2 ${styles.border}`}> {el} </p>
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
      </div>
      <>
        {template && (
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
        )}
      </>
    </>
  );
}

export default SelectContributor;
