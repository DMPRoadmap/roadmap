import React, { useContext, useEffect, useState } from 'react';
import Select from 'react-select';
import Swal from 'sweetalert2';
import { GlobalContext } from '../context/Global.jsx';
import { getRegistry } from '../../services/DmpServiceApi';
import { createOptions } from '../../utils/GeneratorUtils';
import styles from '../assets/css/form.module.css';

function SelectMultipleList({
  label,
  registryId,
  propName,
  changeValue,
  tooltip,
  header,
  fragmentId,
}) {
  const [list, setList] = useState([]);
  const [options, setOptions] = useState(null);
  const { formData, subData, setSubData, locale } = useContext(GlobalContext);

  /* A hook that is called when the component is mounted.
  It is used to set the options of the select list. */
  useEffect(() => {
    let isMounted = true;
    if (isMounted) {
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
    }
  }, [registryId, locale]);

  /**
   * It takes the value of the input field and adds it to the list array.
   * @param e - the event object
   */
  const handleChangeList = (e) => {
    const copyList = [...(list || []), e.value];
    changeValue({ target: { propName, value: [...copyList] } });
    setList(copyList);
  };

  /* A hook that is called when the component is mounted.
  It is used to set the options of the select list. */
  useEffect(() => {
    if (subData) {
      setList(subData[propName]);
    } else {
      setList(formData?.[fragmentId]?.[propName]);
    }
  }, [fragmentId, propName]);

  /**
   * This function handles the deletion of an element from a list and displays a confirmation message using the Swal library.
   */
  const handleDeleteList = (e, idx) => {
    e.preventDefault();
    e.stopPropagation();
    Swal.fire({
      title: 'Ëtes-vous sûr ?',
      text: 'Voulez-vous vraiment supprimer cet élément ?',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#3085d6',
      cancelButtonColor: '#d33',
      cancelButtonText: 'Annuler',
      confirmButtonText: 'Oui, supprimer !',
    }).then((result) => {
      if (result.isConfirmed) {
        const newList = [...list];
        // only splice array when item is found
        if (idx > -1) {
          newList.splice(idx, 1); // 2nd parameter means remove one item only
        }
        setList(newList);
        setSubData({ ...subData, [propName]: newList });
        Swal.fire('Supprimé!', 'Opération effectuée avec succès!.', 'success');
      }
    });
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
        <div className={styles.input_label}>Sélectionnez une valeur de la liste.</div>
        <div className="row">
          <div className={`col-md-12 ${styles.select_wrapper}`}>
            <Select
              onChange={handleChangeList}
              options={options}
              name={propName}
              defaultValue={{
                label: subData ? subData[propName] : '',
                value: subData ? subData[propName] : '',
              }}
            />
          </div>
        </div>
        <div style={{ margin: '20px 30px 20px 20px' }}>
          {header && <p>{header}</p>}
          {list &&
            list.map((el, idx) => (
              <div key={idx} className="row border">
                <div className="col-md-11">
                  <p className={`m2 ${styles.border}`}> {el} </p>
                </div>
                <div className="col-md-1" style={{ marginTop: '8px' }}>
                  <span>
                    <a className="text-primary" href="#" aria-hidden="true" onClick={(e) => handleDeleteList(e, idx)}>
                      <i className="fa fa-times" />
                    </a>
                  </span>
                </div>
              </div>
            ))}
        </div>
      </div>
    </>
  );
}

export default SelectMultipleList;
