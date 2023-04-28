import React, { useContext, useEffect, useState } from 'react';
import { Editor } from '@tinymce/tinymce-react';
import { GlobalContext } from '../context/Global.jsx';
import styles from '../assets/css/form.module.css';

/* This is a React functional component that renders a TinyMCE editor for text input. It receives several props including `label`, `name`, `changeValue`,
`tooltip`, `level`, and `schemaId`. It uses the `useContext` hook to access the `form` and `temp` values from the `GlobalContext`. It also uses the
`useState` hook to set the initial state of the `text` variable to `<p></p>`. */
function TinyArea({
  label, propName, changeValue, tooltip, level, fragmentId
}) {
  const { formData, subData } = useContext(GlobalContext);
  const [text, setText] = useState('<p></p>');

  /* This is a useEffect hook that runs when the component mounts and whenever the `level` or `name` props change. It sets the initial value of the `text`
state based on the `temp` or `form` context values for the given `name` and `fragmentId`, or sets it to `<p></p>` if no value is found. If the `level`
prop is 1, it uses the `defaultValue` as the `updatedText`, otherwise it uses the `temp` value or `<p></p>`. Finally, it sets the `text` state to the
`updatedText` value. */
  useEffect(() => {
    if (level === 1) {
      setText(formData?.[fragmentId]?.[propName] || "<p></p>")
    } else {
      setText(subData ? subData[propName] : "<p></p>")
    }
  }, [fragmentId, propName]);

  const handleChange = (newText) => {
    changeValue({ target: { name: propName, value: newText } });
    setText(newText);
  };
  return (
    <div className={`form-group ticket-summernote mr-4 ml-4 ${styles.form_margin}`}>
      <div className="row">
        <div className={styles.label_form}>
          <strong className={styles.dot_label}></strong>
          <label>{label}</label>
          {tooltip && (
            <span className="" data-toggle="tooltip" data-placement="top" title={tooltip}>
              ?
            </span>
          )}
        </div>

        <div style={{ marginTop: "10px" }}>
          <Editor
            onEditorChange={(newText) => handleChange(newText)}
            // onInit={(evt, editor) => (editorRef.current = editor)}
            value={text}
            name={propName}
            init={{
              branding: false,
              height: 200,
              menubar: false,
              plugins: "table autoresize link advlist lists",
              toolbar: "bold italic underline | fontsizeselect forecolor | bullist numlist | link | table",
              content_style: "body { font-family:Helvetica,Arial,sans-serif; font-size:14px }",
              skin_url: '/tinymce/skins/oxide',
              content_css: ['/tinymce/tinymce.css'],
            }}
          />
        </div>
      </div>
    </div>
  );
}

export default TinyArea;
