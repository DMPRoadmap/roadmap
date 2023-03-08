import React, { useContext, useEffect, useState } from 'react';
import Select from 'react-select';
import { getRegistry } from '../../services/DmpServiceApi';
import { createOptions } from '../../utils/GeneratorUtils';
import { GlobalContext } from '../context/Global';

function SelectSingleList({
  label, propName, changeValue, tooltip, registryId,
}) {
  const [options, setoptions] = useState(null);
  const { formData, subData, locale } = useContext(GlobalContext);
  const [error, setError] = useState(null);

  let value;
  if (subData && typeof subData[propName] !== 'object') {
    value = subData[propName];
  } else if (formData && typeof formData[propName] !== 'object') {
    value = formData[propName];
  } else {
    value = '';
  }
  /*
  A hook that is called when the component is mounted.
  It is used to set the options of the select list.
  */
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
      .catch((err) => {
        setError(err);
      });
    return () => {
      isMounted = false;
    };
  }, [registryId, locale]);

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleChangeList = (e) => {
    if (propName === 'funder') {
      changeValue({ target: { name: propName, value: e.object } });
    } else {
      changeValue({ target: { name: propName, value: e.value } });
    }
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
              name={propName}
              inputValue={value}
            />
          </div>
        </div>
      </div>
    </>
  );
}

export default SelectSingleList;
