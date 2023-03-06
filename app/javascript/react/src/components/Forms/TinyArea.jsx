import React, { useContext, useEffect, useState } from 'react';
import { Editor } from '@tinymce/tinymce-react';
import { GlobalContext } from '../context/Global';

function TinyArea({
  label, name, changeValue, tooltip, level,
}) {
  const { form, temp } = useContext(GlobalContext);
  const [text, settext] = useState('<p></p>');

  useEffect(() => {
    const defaultValue = temp ? temp[name] : form[name] ? form[name] : '<p></p>';
    const updatedText = level === 1 ? defaultValue : temp ? temp[name] : '<p></p>';
    settext(updatedText);
  }, [level, name]);

  const handleChange = (e) => {
    changeValue({ target: { name, value: e } });
    settext(e);
  };
  return (
    <div className="form-group ticket-summernote mr-4 ml-4 border">
      <label className="form-label mb-0 mt-2 text-lg">{label}</label>
      {tooltip && (
        <span className="m-4" data-toggle="tooltip" data-placement="top" title={tooltip}>
          ?
        </span>
      )}
      <Editor
        onEditorChange={(newText) => handleChange(newText)}
        // onInit={(evt, editor) => (editorRef.current = editor)}
        value={text}
        name={name}
        init={{
          branding: false,
          height: 230,
          menubar: false,
          plugins: [
            'table autoresize link paste advlist lists',
          ],
          toolbar:
            'bold italic underline | fontsizeselect forecolor | bullist numlist | link | table',
          content_style: 'body { font-family:Helvetica,Arial,sans-serif; font-size:14px }',
          skin_url: '/tinymce/skins/oxide',
          content_css: ['/tinymce/tinymce.css'],
        }}
      />
    </div>
  );
}

export default TinyArea;
