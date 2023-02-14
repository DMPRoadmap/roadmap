import React, { useContext, useEffect, useState } from "react";

import Modal from "react-bootstrap/Modal";
import BuilderForm from "../Builder/BuilderForm";
import Select from "react-select";
import { deleteByIndex, parsePatern } from "../../utils/GeneratorUtils";
import { Button } from "react-bootstrap";
import { GlobalContext } from "../context/Global";
import swal from "sweetalert";
import toast from "react-hot-toast";

function SelectContributor({ label, arrayList, name, changeValue, template, keyValue, level, tooltip }) {
  const [list, setlist] = useState([]);
  let registerFile = require(`../../data/templates/${template}-template.json`);

  const [show, setShow] = useState(false);
  const [options, setoptions] = useState(null);
  const [selectObject, setselectObject] = useState([]);
  const { form, setform, temp, settemp } = useContext(GlobalContext);
  const [index, setindex] = useState(null);

  /**
   * It closes the modal and resets the state of the modal.
   */
  const handleClose = () => {
    setShow(false);
    settemp(null);
    setindex(null);
  };
  /**
   * The function takes a boolean value as an argument and sets the state of the show variable to the value of the argument.
   * @param isOpen - boolean
   */
  const handleShow = (isOpen) => {
    setShow(isOpen);
  };

  /* It's a useEffect hook that is called when the component is mounted. It is used to set the options of the select list. */
  useEffect(() => {
    if (!form[keyValue]) {
      return;
    }
    const patern = registerFile.to_string;
    if (!patern.length) {
      return;
    }
    setlist(form[keyValue].map((el) => parsePatern(el.person, patern)));
  }, [form[keyValue], registerFile]);

  /* A hook that is called when the component is mounted. It is used to set the options of the select list. */
  useEffect(() => {
    const options = arrayList.map((option) => ({
      value: option.firstName + " " + option.lastName,
      label: option.firstName + " " + option.lastName,
      object: option,
    }));
    setoptions(options);
  }, []);

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleChangeList = (e) => {
    const patern = registerFile.to_string;
    const { object, value } = e;

    if (patern.length > 0) {
      setselectObject([...selectObject, object]);
      const parsedPatern = parsePatern(object, registerFile.to_string);
      setlist([...list, parsedPatern]);
      changeValue({ target: { name, value: [...selectObject, object] } });

      const newObject = { person: object, role: "from list" };
      const arr3 = form[keyValue] ? [...form[keyValue], newObject] : [newObject];
      setform({ ...form, [keyValue]: arr3 });
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
      title: "Ëtes-vous sûr ?",
      text: "Voulez-vous vraiment supprimer cet élément ?",
      icon: "info",
      buttons: true,
      dangerMode: true,
    }).then((willDelete) => {
      if (willDelete) {
        const newList = [...list];
        setlist(deleteByIndex(newList, idx));
        const deleteIndex = deleteByIndex(form[keyValue], idx);
        setform({ ...form, [keyValue]: deleteIndex });
        swal("Opération effectuée avec succès!", {
          icon: "success",
        });
      }
    });
  };

  /**
   * If the index is not null, then delete the item at the index, add the temp item to the end of the array,
   * and then splice the item from the list array.
   * If the index is null, then just save the item.
   */
  const handleAddToList = () => {
    if (index !== null) {
      const objectPerson = { person: temp, role: "from create" };
      setform({ ...form, [keyValue]: [...deleteByIndex(form[keyValue], index), objectPerson] });
      const parsedPatern = parsePatern(temp, registerFile.to_string);
      setlist([...deleteByIndex([...list], index), parsedPatern]);
    } else {
      handleSave();
    }
    toast.success("Enregistrement a été effectué avec succès !");
    settemp(null);
    handleClose();
  };

  /**
   * When the user clicks the save button, the function will take the temporary person object and add it to the form object, then it will parse the
   * temporary person object and add it to the list array, then it will close the modal and set the temporary person object to null.
   */
  const handleSave = () => {
    const objectPerson = { person: temp, role: "from create" };
    setform({ ...form, [keyValue]: [...(form[keyValue] || []), objectPerson] });
    const parsedPatern = parsePatern(temp, registerFile.to_string);
    setlist([...list, parsedPatern]);
    handleClose();
    settemp(null);
  };

  /**
   * It sets the state of the temp variable to the value of the form[keyValue][idx] variable.
   * @param idx - the index of the item in the array
   */
  const handleEdit = (idx) => {
    settemp(form[keyValue][idx]["person"]);
    setShow(true);
    setindex(idx);
  };

  return (
    <>
      <div className="form-group">
        <label>{label}</label>
        {tooltip && (
          <span className="m-4" data-toggle="tooltip" data-placement="top" title={tooltip}>
            ?
          </span>
        )}
        <div className="row">
          <div className="col-10">
            <Select
              onChange={handleChangeList}
              options={options}
              name={name}
              //defaultValue={isEdit ? isEdit[name] : "Sélectionnez une valeur de la liste ou saisissez une nouvelle."}
              defaultValue={{
                label: temp ? temp[name] : "Sélectionnez une valeur de la liste ou saisissez une nouvelle.",
                value: temp ? temp[name] : "Sélectionnez une valeur de la liste ou saisissez une nouvelle.",
              }}
            />
          </div>
          <div className="col-2">
            <i className="fas fa-plus-square text-primary mt-2" onClick={handleShow}></i>
          </div>
        </div>

        <div style={{ margin: "20px 90px 20px 20px" }}>
          {list &&
            list.map((el, idx) => (
              <div key={idx} className="row border">
                <div className="col-10">
                  <p className="border m-2"> {list[idx]} </p>
                </div>
                <div className="col-1">
                  {level === 1 && <i className="fa fa-edit m-3 text-primary" aria-hidden="true" onClick={() => handleEdit(idx)}></i>}
                </div>
                <div className="col-1">
                  <i className="fa fa-close m-3  text-danger" aria-hidden="true" onClick={() => handleDeleteListe(idx)}></i>
                </div>
              </div>
            ))}
        </div>
      </div>
      <>
        <Modal show={show} onHide={handleClose}>
          <Modal.Body>
            <BuilderForm shemaObject={registerFile} level={level + 1}></BuilderForm>
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

export default SelectContributor;
