import React, { useContext, useEffect, useState } from 'react';
import Select from 'react-select';
import { getRegistry } from '../../services/DmpServiceApi';
import { createOptions } from '../../utils/GeneratorUtils';
import { GlobalContext } from '../context/Global.jsx';
import styles from '../assets/css/form.module.css';

/* This is a functional component in JavaScript React that renders a select list with options fetched from a registry. It takes in several props such as
label, name, changeValue, tooltip, registry, and schemaId. It uses the useState and useEffect hooks to manage the state of the options and to fetch
the options from the registry when the component mounts. It also defines a handleChangeList function that is called when an option is selected from
the list, and it updates the value of the input field accordingly. Finally, it returns the JSX code that renders the select list with the options. */
function SelectSingleList({
  label, propName, changeValue, tooltip, registryId, fragmentId
}) {
  const [options, setOptions] = useState([{value:'', label:''}]);
  const { formData, subData, locale } = useContext(GlobalContext);
  const [error, setError] = useState(null);

  let value;
  if (subData && typeof subData?.[fragmentId]?.[propName] !== 'object') {
    value = subData?.[fragmentId]?.[propName];
  } else if (formData && typeof formData?.[fragmentId]?.[propName] !== 'object') {
    value = formData?.[fragmentId]?.[propName];
  } else {
    value = '';
  }
  const selectedOption = options.find((opt) => opt.value == value);
  /*
  A hook that is called when the component is mounted.
  It is used to set the options of the select list.
  */
  useEffect(() => {
    let isMounted = true;
    if (isMounted) {
      getRegistry(registryId)
        .then((res) => {
          setOptions(createOptions(res.data, locale));
          console.log(value, createOptions(res.data, locale))
        })
        .catch((err) => {
          setError(err);
        });
      return () => {
        isMounted = false;
      };
    }
  }, [registryId, locale]);

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleChangeList = (e) => {
    if (!e) return { target: { name: propName, value: '' } }

    if (propName === 'funder') {
      changeValue({ target: { name: propName, value: e.object } });
    } else {
      changeValue({ target: { name: propName, value: e.value } });
    }
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
        <div className="row">
          <div className="col-md-10">
            <Select
              onChange={handleChangeList}
              options={options}
              name={propName}
              value={selectedOption}
            />
          </div>
        </div>
      </div>
    </>
  );
}

export default SelectSingleList;
