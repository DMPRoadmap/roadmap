import React, { useContext, useRef } from "react";
import { GlobalContext } from "../context/Global";
import { Editor } from "@tinymce/tinymce-react";

function TinyArea({ label, name, changeValue, tooltip }) {
  const { form, temp } = useContext(GlobalContext);

  const editorRef = useRef(null);
  const log = () => {
    if (editorRef.current) {
      console.log(editorRef.current.getContent());
    }
  };

  const handleChange = (e) => {
    changeValue({ target: { name: name, value: e } });
  };
  return (
    <div className="form-group ticket-summernote mr-4 ml-4 border">
      <div className="row">
        <div>
          <label className="form-label mb-0 mt-2 text-lg">{label}</label>
          {tooltip && (
            <span className="m-4" data-toggle="tooltip" data-placement="top" title={tooltip}>
              ?
            </span>
          )}
        </div>
        <div>
          <Editor
            apiKey={"xvzn7forg8ganzrt5s9id02obr84ky126f85409p7ny84ava"}
            onEditorChange={(newText) => handleChange(newText)}
            onInit={(evt, editor) => (editorRef.current = editor)}
            initialValue={temp ? temp[name] : form[name] ? form[name] : "<p></p>"}
            name={name}
            init={{
              height: 200,
              menubar: false,
              plugins: [
                "advlist autolink lists link image charmap print preview anchor",
                "searchreplace visualblocks code fullscreen",
                "insertdatetime media table paste code help wordcount",
              ],
              toolbar:
                "undo redo | formatselect | " +
                "bold italic backcolor | alignleft aligncenter " +
                "alignright alignjustify | bullist numlist outdent indent | " +
                "removeformat | help",
              content_style: "body { font-family:Helvetica,Arial,sans-serif; font-size:14px }",
            }}
          />
        </div>
      </div>
    </div>
  );
}

export default TinyArea;
