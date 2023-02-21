import React, { useContext, useEffect, useState } from "react";
import BuilderForm from "../Builder/BuilderForm";
import Select from "react-select";
import { checkRequiredForm, deleteByIndex, getLabelName, parsePatern } from "../../utils/GeneratorUtils";
import { Modal, Button } from "react-bootstrap";
import { GlobalContext } from "../context/Global";
import swal from "sweetalert";
import toast from "react-hot-toast";
import { getRegistry, getRegistryValue, getSchema } from "../../services/DmpServiceApi";

function SelectWithCreate({ label, registry, name, changeValue, template, keyValue, level, tooltip, header }) {
  const [list, setlist] = useState([]);

  const [show, setShow] = useState(false);
  const [options, setoptions] = useState(null);
  const [selectObject, setselectObject] = useState([]);
  const { form, setform, temp, settemp, lng } = useContext(GlobalContext);
  const [index, setindex] = useState(null);

  const [registerFile, setregisterFile] = useState(null);

  /* A hook that is called when the component is mounted. It is used to set the options of the select list. */
  useEffect(() => {
    getSchema(template, "token").then((el) => {
      setregisterFile(el);
      if (form[keyValue]) {
        const patern = el.to_string;
        if (patern.length > 0) {
          Promise.all(form[keyValue].map((el) => parsePatern(el, patern))).then((listParsed) => {
            setlist(listParsed);
          });
        }
      }
    });
  }, [template, form[keyValue]]);

  /* A hook that is called when the component is mounted. It is used to set the options of the select list. */
  useEffect(() => {
    let isMounted = true;
    const createOptions = (data) => {
      return data.map((option) => ({
        value: lng === "fr" ? option?.fr_FR || option?.label?.fr_FR : option?.en_GB || option?.label?.en_GB,
        label: lng === "fr" ? option?.fr_FR || option?.label?.fr_FR : option?.en_GB || option?.label?.en_GB,
        object: option,
      }));
    };
    const setOptions = (data) => {
      if (isMounted) {
        setoptions(data);
      }
    };
    getRegistryValue(registry, "token")
      .then((res) => {
        if (res) {
          setOptions(createOptions(res));
        } else {
          return getRegistry(registry, "token").then((resRegistry) => {
            setOptions(createOptions(resRegistry));
          });
        }
      })
      .catch((error) => {
        // handle errors
      });
    return () => {
      isMounted = false;
    };
  }, [registry, lng]);

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

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleChangeList = (e) => {
    const patern = registerFile.to_string;
    const parsedPatern = patern.length > 0 ? parsePatern(e.object, patern) : null;
    const updatedList = patern.length > 0 ? [...list, parsedPatern] : [...list, e.value];
    setlist(updatedList);
    setselectObject(patern.length > 0 ? [...selectObject, e.object] : selectObject);
    changeValue({ target: { name: name, value: patern.length > 0 ? [...selectObject, e.object] : e.value } });
    setform({ ...form, [keyValue]: form[keyValue] ? [...form[keyValue], ...[e.object]] : [e.object] });
  };

  /**
   * It creates a new array, then removes the item at the index specified by the parameter, then sets the state to the new array.
   * @param idx - the index of the item in the array
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
    if (!temp) {
      handleClose();
      return;
    }

    const checkForm = checkRequiredForm(registerFile, temp);
    if (checkForm) {
      toast.error("Veuiller remplire le champs " + getLabelName(checkForm, registerFile));
    } else {
      if (index !== null) {
        const deleteIndex = deleteByIndex(form[keyValue], index);
        const concatedObject = [...deleteIndex, temp];
        setform({ ...form, [keyValue]: concatedObject });
        const newList = deleteByIndex([...list], index);
        const parsedPatern = parsePatern(temp, registerFile.to_string);
        const copieList = [...newList, parsedPatern];
        setlist(copieList);
        settemp(null);
        handleClose();
      } else {
        handleSave();
      }
      toast.success("Enregistrement a été effectué avec succès !");
    }
  };

  /**
   * I'm trying to add a new object to an array of objects, and then add that array to a new object.
   */
  const handleSave = () => {
    let newObject = form[keyValue] ? [...form[keyValue], temp] : [temp];
    setform({ ...form, [keyValue]: newObject });
    setlist([...list, parsePatern(temp, registerFile.to_string)]);
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
        <label>{label}</label>
        {tooltip && (
          <span className="m-4" data-toggle="tooltip" data-placement="top" title={tooltip}>
            ?
          </span>
        )}
        <div className="row">
          <div className="col-md-10">
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
          <div className="col-md-2">
            <i className="fas fa-plus-square text-primary icon-margin-top mt-3" onClick={handleShow}></i>
          </div>
        </div>

        {form[keyValue] && list && (
          <table style={{ marginTop: "20px" }} className="table table-bordered">
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
                  <td style={{ width: "10%" }}>
                    <div className="col-md-1">
                      {level === 1 && <i className="fa fa-edit icon-margin-top text-primary" aria-hidden="true" onClick={() => handleEdit(idx)}></i>}
                    </div>
                    <div className="col-md-1">
                      <i className="fa fa-times icon-margin-top text-danger" aria-hidden="true" onClick={() => handleDeleteListe(idx)}></i>
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

export default SelectWithCreate;
