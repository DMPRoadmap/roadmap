import React, { useContext, useEffect, useState } from 'react';
import Select from 'react-select';
import { Modal, Button } from 'react-bootstrap';
import swal from 'sweetalert';
import toast from 'react-hot-toast';
import { GlobalContext } from '../context/Global';
import {
  checkRequiredForm,
  createOptions,
  deleteByIndex,
  getLabelName,
  parsePattern,
} from '../../utils/GeneratorUtils';
import BuilderForm from '../Builder/BuilderForm';
import { getRegistry, getSchema } from '../../services/DmpServiceApi';

function SelectWithCreate({
  label,
  registryId,
  name,
  changeValue,
  templateId,
  keyValue,
  level,
  tooltip,
  header,
}) {
  const [list, setlist] = useState([]);

  const [show, setShow] = useState(false);
  const [options, setoptions] = useState(null);
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
      if (formData[keyValue]) {
        const patern = res.data.to_string;
        if (patern.length > 0) {
          Promise.all(
            formData[keyValue].map((el) => parsePattern(el, patern)),
          ).then((listParsed) => {
            setlist(listParsed);
          });
        }
      }
    });
  }, [templateId, formData[keyValue]]);

  /* A hook that is called when the component is mounted.
  It is used to set the options of the select list. */
  useEffect(() => {
    let isMounted = true;
    const setOptions = (data) => {
      if (isMounted) {
        setoptions(data);
      }
    };
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
  }, [registryId, locale]);

  /**
   * It closes the modal and resets the state of the modal.
   */
  const handleClose = () => {
    setShow(false);
    setSubData(null);
    setindex(null);
  };
  /**
   * The function takes a boolean value as an argument and sets the state of the
   * show variable to the value of the argument.
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
    const parsedPatern = pattern.length > 0 ? parsePattern(e.object, pattern) : null;
    const updatedList = pattern.length > 0 ? [...list, parsedPatern] : [...list, e.value];
    setlist(updatedList);
    setselectObject(
      pattern.length > 0 ? [...selectObject, e.object] : selectObject,
    );
    changeValue({
      target: {
        name,
        value: pattern.length > 0 ? [...selectObject, e.object] : e.value,
      },
    });
    setFormData({
      ...formData,
      [keyValue]: formData[keyValue]
        ? [...formData[keyValue], ...[e.object]]
        : [e.object],
    });
  };

  /**
   * It creates a new array, then removes the item at the index specified by the parameter,
   * then sets the state to the new array.
   * @param idx - the index of the item in the array
   */
  const handleDeleteListe = (idx) => {
    swal({
      title: 'Ëtes-vous sûr ?',
      text: 'Voulez-vous vraiment supprimer cet élément ?',
      icon: 'info',
      buttons: true,
      dangerMode: true,
    }).then((willDelete) => {
      if (willDelete) {
        const newList = [...list];
        setlist(deleteByIndex(newList, idx));
        const deleteIndex = deleteByIndex(formData[keyValue], idx);
        setFormData({ ...formData, [keyValue]: deleteIndex });
        swal('Opération effectuée avec succès!', {
          icon: 'success',
        });
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
        const deleteIndex = deleteByIndex(formData[keyValue], index);
        const concatedObject = [...deleteIndex, subData];
        setFormData({ ...formData, [keyValue]: concatedObject });
        const newList = deleteByIndex([...list], index);
        const parsedPatern = parsePattern(subData, template.to_string);
        const copieList = [...newList, parsedPatern];
        setlist(copieList);
        setSubData(null);
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
    const newObject = formData[keyValue] ? [...formData[keyValue], subData] : [subData];
    setFormData({ ...formData, [keyValue]: newObject });
    setlist([...list, parsePattern(subData, template.to_string)]);
    handleClose();
    setSubData(null);
  };

  /**
   * It sets the state of the subData variable to the value of the formData[keyValue][idx] variable.
   * @param idx - the index of the item in the array
   */
  const handleEdit = (idx) => {
    setSubData(formData[keyValue][idx]);
    setShow(true);
    setindex(idx);
  };

  return (
    <>
      <fieldset className="sub-fragment registry">
        <legend className="sub-fragment" data-toggle="tooltip" data-original-title={tooltip}>
          {label}
        </legend>
        <div className="col-md-12 dynamic-field">
          <Select
            className='form-control'
            onChange={handleChangeList}
            options={options}
            name={name}
            defaultValue={{
              label: subData
                ? subData[name]
                : 'Sélectionnez une valeur de la liste ou saisissez une nouvelle.',
              value: subData
                ? subData[name]
                : 'Sélectionnez une valeur de la liste ou saisissez une nouvelle.',
            }}
          />
          <span>
            <a className="text-primary" href="#" onClick={handleShow}>
              <i className="fas fa-plus-square" />
            </a>
          </span>
        </div>

        {formData[keyValue] && list && (
          <table style={{ marginTop: '20px' }} className="table table-bordered">
            <thead>
              {formData[keyValue].length > 0 && header && (
                <tr>
                  <th scope="col">{header}</th>
                  <th scope="col"></th>
                </tr>
              )}
            </thead>
            <tbody>
              {formData[keyValue].map((el, idx) => (
                <tr key={idx}>
                  <td scope="row">
                    <p className="border m-2"> {list[idx]} </p>
                  </td>
                  <td style={{ width: '10%' }}>
                    <div className="col-md-1">
                      {level === 1 && (
                        <span>
                          <a
                            className="text-primary"
                            href="#"
                            aria-hidden="true"
                            onClick={() => handleEdit(idx)}
                          >
                            <i className="fa fa-edit" />
                          </a>
                        </span>
                      )}
                    </div>
                    <div className="col-md-1">
                      <span>
                        <a
                          className="text-danger"
                          href="#"
                          aria-hidden="true"
                          onClick={() => handleDeleteListe(idx)}
                        >
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
            <BuilderForm shemaObject={template} level={level + 1}></BuilderForm>
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
