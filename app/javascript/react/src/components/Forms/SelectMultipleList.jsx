import React, { useContext, useEffect, useState } from "react";
import Select from "react-select";
import { GlobalContext } from "../context/Global";
import swal from "sweetalert";
import { getRegistry, getRegistryValue } from "../../services/DmpServiceApi";

function SelectMultipleList({ label, registry, name, changeValue, tooltip, header }) {
  const [list, setlist] = useState([]);
  const [options, setoptions] = useState(null);
  const { temp, settemp, lng } = useContext(GlobalContext);

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
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleChangeList = (e) => {
    const copieList = [...(list || []), e.value];
    changeValue({ target: { name: name, value: [...copieList] } });
    setlist(copieList);
  };

  /* A hook that is called when the component is mounted. It is used to set the options of the select list. */
  useEffect(() => {
    if (temp) {
      setlist(temp[name]);
    }
  }, [temp]);

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
        // only splice array when item is found
        if (idx > -1) {
          newList.splice(idx, 1); // 2nd parameter means remove one item only
        }
        setlist(newList);
        settemp({ ...temp, [name]: newList });
        swal("Opération effectuée avec succès!", {
          icon: "success",
        });
      }
    });
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
        </div>
        <div style={{ margin: "20px 30px 20px 20px" }}>
          {header && <p>{header}</p>}
          {list &&
            list.map((el, idx) => (
              <div key={idx} className="row border">
                <div className="col-md-11">
                  <p className="border m-2"> {list[idx]} </p>
                </div>
                <div className="col-md-1">
                  <i className="fa fa-times icon-margin-top text-danger" aria-hidden="true" onClick={() => handleDeleteListe(idx)}></i>
                </div>
              </div>
            ))}
        </div>
      </div>
    </>
  );
}

export default SelectMultipleList;
