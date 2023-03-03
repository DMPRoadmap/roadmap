import React, { useContext, useEffect, useState } from 'react';
import Select from 'react-select';
import { Modal, Button } from 'react-bootstrap';
import swal from 'sweetalert';
import toast from 'react-hot-toast';
import { GlobalContext } from '../context/Global';
import {
  checkRequiredForm,
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
    form, setform, temp, settemp, locale,
  } = useContext(GlobalContext);
  const [index, setindex] = useState(null);

  const [template, setTemplate] = useState(null);

  /* A hook that is called when the component is mounted.
  It is used to set the options of the select list. */
  useEffect(() => {
    getSchema(templateId).then((res) => {
      setTemplate(res.data);
      if (form[keyValue]) {
        const patern = res.data.to_string;
        if (patern.length > 0) {
          Promise.all(
            form[keyValue].map((el) => parsePattern(el, patern)),
          ).then((listParsed) => {
            setlist(listParsed);
          });
        }
      }
    });
  }, [templateId, form[keyValue]]);

  /* A hook that is called when the component is mounted.
  It is used to set the options of the select list. */
  useEffect(() => {
    let isMounted = true;
    const createOptions = (data) => data.map((option) => ({
      value: option.label ? option.label[locale] : option[locale],
      label: option.label ? option.label[locale] : option[locale],
      object: option,
    }));
    const setOptions = (data) => {
      if (isMounted) {
        setoptions(data);
      }
    };
    getRegistry(registryId)
      .then((res) => {
        if (res) {
          setOptions(createOptions(res.data));
        } else {
          return getRegistry(registryId).then((resRegistry) => {
            setOptions(createOptions(resRegistry.data));
          });
        }
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
    settemp(null);
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
    setform({
      ...form,
      [keyValue]: form[keyValue]
        ? [...form[keyValue], ...[e.object]]
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
        const deleteIndex = deleteByIndex(form[keyValue], idx);
        setform({ ...form, [keyValue]: deleteIndex });
        swal('Opération effectuée avec succès!', {
          icon: 'success',
        });
      }
    });
  };

  /**
   * If the index is not null, then delete the item at the index,
   * add the temp item to the end of the array,
   * and then splice the item from the list array.
   * If the index is null, then just save the item.
   */
  const handleAddToList = () => {
    if (!temp) {
      handleClose();
      return;
    }

    const checkForm = checkRequiredForm(template, temp);
    if (checkForm) {
      toast.error(
        `Veuiller remplire le champs ${getLabelName(checkForm, template)}`,
      );
    } else {
      if (index !== null) {
        const deleteIndex = deleteByIndex(form[keyValue], index);
        const concatedObject = [...deleteIndex, temp];
        setform({ ...form, [keyValue]: concatedObject });
        const newList = deleteByIndex([...list], index);
        const parsedPatern = parsePattern(temp, template.to_string);
        const copieList = [...newList, parsedPatern];
        setlist(copieList);
        settemp(null);
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
    const newObject = form[keyValue] ? [...form[keyValue], temp] : [temp];
    setform({ ...form, [keyValue]: newObject });
    setlist([...list, parsePattern(temp, template.to_string)]);
    handleClose();
    settemp(null);
  };

  /**
   * It sets the state of the temp variable to the value of the form[keyValue][idx] variable.
   * @param idx - the index of the item in the array
   */
  const handleEdit = (idx) => {
    settemp(form[keyValue][idx]);
    setShow(true);
    setindex(idx);
  };

  return (
    <>
      <div className="form-group">
        <label className="control-label">{label}</label>
        {tooltip && (
          <span
            className="m-4"
            data-toggle="tooltip"
            data-placement="top"
            title={tooltip}
          >
            ?
          </span>
        )}
        <div className="row">
          <div className="col-md-10">
            <Select
              onChange={handleChangeList}
              options={options}
              name={name}
              // defaultValue={isEdit ? isEdit[name] : "Sélectionnez une valeur de la liste ou saisissez une nouvelle."}
              defaultValue={{
                label: temp
                  ? temp[name]
                  : 'Sélectionnez une valeur de la liste ou saisissez une nouvelle.',
                value: temp
                  ? temp[name]
                  : 'Sélectionnez une valeur de la liste ou saisissez une nouvelle.',
              }}
            />
          </div>
          <div className="col-md-2" style={{ marginTop: "8px" }}>
            <span>
              <a className="text-primary" href="#" onClick={handleShow}>
                <i className="fas fa-plus-square" />
              </a>
            </span>
          </div>
        </div>

        {form[keyValue] && list && (
          <table style={{ marginTop: '20px' }} className="table table-bordered">
            <thead>
              {form[keyValue].length > 0 && header && (
                <tr>
                  <th scope="col">{header}</th>
                  <th scope="col"></th>
                </tr>
              )}
            </thead>
            <tbody>
              {form[keyValue].map((el, idx) => (
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
      </div>
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
