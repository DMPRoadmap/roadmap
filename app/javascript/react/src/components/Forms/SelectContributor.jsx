import React, { useContext, useEffect, useState } from 'react';
import { Modal, Button } from 'react-bootstrap';
import Select from 'react-select';
import swal from 'sweetalert';
import toast from 'react-hot-toast';
import BuilderForm from '../Builder/BuilderForm';
import { deleteByIndex, parsePattern } from '../../utils/GeneratorUtils';
import { GlobalContext } from '../context/Global';
import { getContributors, getSchema } from '../../services/DmpServiceApi';

function SelectContributor({
  label,
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
    formData, setFormData, subData, setSubData, locale, dmpId,
  } = useContext(GlobalContext);
  const [index, setindex] = useState(null);
  const [template, settemplate] = useState(null);
  const [role, setrole] = useState(null);

  /* A hook that is called when the component is mounted. */
  useEffect(() => {
    getContributors(dmpId, templateId).then((res) => {
      const builtOptions = res.data.results.map((option) => ({
        value: option.id,
        label: option.text,
        object: option,
      }));
      setoptions(builtOptions);
    });
  }, []);

  /* A hook that is called when the component is mounted. */
  useEffect(() => {
    getSchema(templateId).then((res) => {
      setrole(res.properties.role[`const@${locale}`]);
      settemplate(res.properties.person.schema_id);
      const personTemplateId = res.properties.person.schema_id;
      getSchema(personTemplateId).then((resSchema) => {
        settemplate(resSchema.data);
      });

      if (!formData[keyValue]) {
        return;
      }
      const pattern = res.to_string;
      if (!pattern.length) {
        return;
      }

      setlist(formData[keyValue].map((el) => parsePattern(el, pattern)));
    });
  }, [formData[keyValue], templateId]);

  /**
   * It closes the modal and resets the state of the modal.
   */
  const handleClose = () => {
    setShow(false);
    setSubData(null);
    setindex(null);
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
      setselectObject([...selectObject, object]);
      const parsedPatern = parsePattern(object, template.to_string);
      setlist([...list, parsedPatern]);
      changeValue({ target: { name, value: [...selectObject, object] } });

      const newObject = { person: object, role };
      const arr3 = formData[keyValue]
        ? [...formData[keyValue], newObject]
        : [newObject];
      setFormData({ ...formData, [keyValue]: arr3 });
    } else {
      changeValue({ target: { name, value } });
      setlist([...list, value]);
    }
  };

  /**
   * I want to delete an item from a list and then update the state of the list.
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
    if (index !== null) {
      const objectPerson = { person: subData, role };
      setFormData({
        ...formData,
        [keyValue]: [...deleteByIndex(formData[keyValue], index), objectPerson],
      });
      const parsedPatern = parsePattern(subData, template.to_string);
      setlist([...deleteByIndex([...list], index), parsedPatern]);
    } else {
      handleSave();
    }
    toast.success('Enregistrement a été effectué avec succès !');
    setSubData(null);
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
    setFormData({ ...formData, [keyValue]: [...(formData[keyValue] || []), objectPerson] });
    const parsedPatern = parsePattern(subData, template.to_string);
    setlist([...list, parsedPatern]);
    handleClose();
    setSubData(null);
  };

  /**
   * It sets the state of the subData variable to the value of the form[keyValue][idx] variable.
   * @param idx - the index of the item in the array
   */
  const handleEdit = (idx) => {
    setSubData(formData[keyValue][idx].person);
    setShow(true);
    setindex(idx);
  };

  return (
    <>
      <div className="form-group">
        <label>{label}</label>
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
              defaultValue={{
                label: subData
                  ? subData[name]
                  : 'Sélectionnez une valeur de la liste ou saisissez une nouvelle.',
                value: subData
                  ? subData[name]
                  : 'Sélectionnez une valeur de la liste ou saisissez une nouvelle.',
              }}
            />
          </div>
          <div className="col-md-2" style={{ marginTop: '8px' }}>
            <span>
              <a
                className="text-primary"
                href="#"
                aria-hidden="true"
                onClick={handleShow}
              >
                <i className="fas fa-plus-square" />
              </a>
            </span>
          </div>
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
      </div>
      <>
        {template && (
          <Modal show={show} onHide={handleClose}>
            <Modal.Body>
              <BuilderForm
                shemaObject={template}
                level={level + 1}
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
