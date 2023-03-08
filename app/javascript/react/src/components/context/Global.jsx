import React, {
  createContext, useEffect, useReducer, useState,
} from 'react';

/**
 * If the formInfo is null, remove the form from localStorage,
 * otherwise return the form with the formInfo.
 * @param form - the current state of the form
 * @param formInfo - This is the object that contains the form data.
 * @returns The reducer is returning a new object that is a combination of the
 * form object and the formInfo object.
 */
const reducer = (form, formInfo) => {
  if (formInfo === null) {
    localStorage.removeItem('formData');
    return {};
  }
  return { ...form, ...formInfo };
};

/* It's getting the form from localStorage. */
const localState = JSON.parse(localStorage.getItem('formData'));
export const GlobalContext = createContext();

/**
 * It's a function that takes a prop called children and returns a GlobalContext.Provider
 * component that has a value prop that is an object with two
 * properties: form and setform.
 * @returns The GlobalContext.Provider is being returned.
 */
function Global({ children }) {
  const [formData, setFormData] = useReducer(reducer, localState || {});
  const [subData, setSubData] = useState(null);
  const [locale, setlocale] = useState(null);
  const [dmpId, setdmpId] = useState(null);

  useEffect(() => {
    /* It's setting the form in localStorage. */
    localStorage.setItem('formData', JSON.stringify(formData));
  }, [formData]);

  return <GlobalContext.Provider value={{
    formData, setFormData, subData, setSubData, locale, setlocale, dmpId, setdmpId,
  }}>{children}</GlobalContext.Provider>;
}

export default Global;
