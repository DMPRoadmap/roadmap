import React, { useContext, useEffect, useState } from "react";

import Select from "react-select";
import { GlobalContext } from "../context/Global";

function SelectSingleList({ label, arrayList, name, changeValue, tooltip }) {
  const [list, setlist] = useState([]);
  const [options, setoptions] = useState(null);

  const { temp, lng } = useContext(GlobalContext);

  /* A hook that is called when the component is mounted. It is used to set the options of the select list. */
  useEffect(() => {
    const options = arrayList.map((option) => ({
      value: lng === "fr" ? option?.fr_FR || option?.label?.fr_FR : option?.en_GB || option?.label?.en_GB,
      label: lng === "fr" ? option?.fr_FR || option?.label?.fr_FR : option?.en_GB || option?.label?.en_GB,
      object: option,
    }));
    setoptions(options);
  }, [arrayList]);

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleChangeList = (e) => {
    changeValue({ target: { name: name, value: e.value } });
    setlist([...list, e.value]);
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
        </div>
      </div>
    </>
  );
}

export default SelectSingleList;
