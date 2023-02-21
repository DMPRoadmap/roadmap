import React, { useContext, useEffect, useState } from "react";
import { Modal, Button } from "react-bootstrap";
import BuilderForm from "../Builder/BuilderForm";
import { GlobalContext } from "../context/Global";
import { checkRequiredForm, createMarkup, deleteByIndex, getLabelName, parsePatern } from "../../utils/GeneratorUtils";
import swal from "sweetalert";
import toast from "react-hot-toast";
import { getSchema } from "../../services/DmpServiceApi";

/**
 * It takes a template name as an argument, loads the template file, and then renders a modal with the template file as a prop.
 * </code>
 * @returns A React component.
 */
function ModalTemplate({ value, template, keyValue, level, tooltip, header }) {
  const [show, setShow] = useState(false);
  const { form, setform, temp, settemp, lng } = useContext(GlobalContext);
  const [index, setindex] = useState(null);

  const [registerFile, setregisterFile] = useState(null);
  useEffect(() => {
    getSchema(template, "token").then((el) => {
      setregisterFile(el);
    });
  }, [template]);

  /**
   * The function sets the show state to false
   */
  const handleClose = () => {
    setShow(false);
    settemp(null);
    setindex(null);
  };

  /**
   * If the temp variable is not empty, check if the form is valid, if it is, add the temp variable to the form, if it's not, show an error message.
   */
  const handleAddToList = () => {
    if (!temp) return handleClose();

    const checkForm = checkRequiredForm(registerFile, temp);
    if (checkForm) return toast.error(`Veuiller remplire le champs ${getLabelName(checkForm, registerFile)}`);

    if (index !== null) {
      const deleteIndex = deleteByIndex(form[keyValue], index);
      setform({ ...form, [keyValue]: [...deleteIndex, temp] });
      settemp(null);
    } else {
      handleSave();
      toast.success("Enregistrement a été effectué avec succès !");
    }
    handleClose();
  };

  /**
   * When the user clicks the save button, the form is updated with the new data, the temp is set to null, and the modal is closed.
   */
  const handleSave = () => {
    let newObject = form[keyValue] || [];
    newObject = [...newObject, temp];
    setform({ ...form, [keyValue]: newObject });
    settemp(null);
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
   * When the user clicks the edit button, the form is populated with the data from the row that was clicked.
   * @param idx - the index of the item in the array
   */
  const handleEdit = (idx) => {
    settemp(form[keyValue][idx]);
    setShow(true);
    setindex(idx);
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
        const deleteIndex = deleteByIndex(form[keyValue], idx);
        setform({ ...form, [keyValue]: deleteIndex });
        //toast.success("Congé accepté");
        swal("Opération effectuée avec succès!", {
          icon: "success",
        });
      }
    });
  };

  return (
    <>
      <div className="border p-2 mb-2">
        <p>{lng === "fr" ? value["form_label@fr_FR"] : value["form_label@en_GB"]}</p>
        {tooltip && (
          <span className="m-4" data-toggle="tooltip" data-placement="top" title={tooltip}>
            ?
          </span>
        )}

        {form[keyValue] && registerFile && (
          <table style={{ marginTop: "20px" }} className="table table-bordered">
            <thead>
              {form[keyValue].length > 0 && registerFile && header && (
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
                    <div className="preview" dangerouslySetInnerHTML={createMarkup(parsePatern(el, registerFile.to_string))}></div>
                  </td>

                  <td style={{ width: "10%" }}>
                    <div className="col-md-1">
                      {level === 1 && <i className="fa fa-edit m-3 text-primary" aria-hidden="true" onClick={() => handleEdit(idx)}></i>}
                    </div>
                    <div className="col-md-1">
                      <i className="fa fa-times m-3  text-danger" aria-hidden="true" onClick={() => handleDeleteListe(idx)}></i>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        <button className="btn btn-primary button-margin" onClick={() => handleShow(true)}>
          Créé
        </button>
      </div>
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
  );
}

export default ModalTemplate;
