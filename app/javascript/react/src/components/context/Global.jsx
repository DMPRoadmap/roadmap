import React, {
  createContext, useEffect, useReducer, useState,
} from 'react';

/**
 * If the incomingFormData is null, remove the formData from localStorage,
 * otherwise return the formData with the incomingFormData.
 * @param formData - the current state of the form
 * @param incomingFormData - This is the object that contains the form data.
 * @returns The reducer is returning a new object that is a combination of the
 * formData object and the incomingFormData object.
 */
const reducer = (formData, incomingFormData) => {
  if (incomingFormData === null) {
    localStorage.removeItem('formData');
    return {};
  }
  return { ...formData, ...incomingFormData };
};

/* It's getting the form from localStorage. */
const formLocalState = JSON.parse(localStorage.getItem('formData'));
export const GlobalContext = createContext();

/**
 * It's a function that takes a prop called children and returns a GlobalContext.Provider
 * component that has a value prop that is an object with two
 * properties: form and setform.
 * @returns The GlobalContext.Provider is being returned.
 */
function Global({ children }) {
  const [formData, setFormData] = useReducer(reducer, formLocalState || {});
  const [subData, setSubData] = useState({});
  const [locale, setlocale] = useState(null);
  const [dmpId, setdmpId] = useState(null);

  useEffect(() => {
    /* It's setting the form in localStorage. */
    localStorage.setItem('formData', JSON.stringify(formData));
  }, [formData]);

  return (
    <GlobalContext.Provider
      value={{
        formData,
        setFormData,
        subData,
        setSubData,
        locale,
        setlocale,
        dmpId,
        setdmpId,
      }}
    >
      {children}
    </GlobalContext.Provider>
  );
}

export default Global;
