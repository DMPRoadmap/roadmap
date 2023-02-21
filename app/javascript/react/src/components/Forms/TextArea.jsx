import React, { useContext, useEffect, useState } from "react";
//draft js
import { EditorState, convertToRaw, ContentState } from "draft-js";
import { Editor } from "react-draft-wysiwyg";
import draftToHtml from "draftjs-to-html";
import htmlToDraft from "html-to-draftjs";
import { GlobalContext } from "../context/Global";

function TextArea({ label, name, changeValue, tooltip }) {
  const { form, temp } = useContext(GlobalContext);
  /* Setting the initial state of the editor. */
  useEffect(() => {
    const blocksFromHtml = htmlToDraft(temp ? temp[name] : form[name] ? form[name] : "<p></p>");
    const { contentBlocks, entityMap } = blocksFromHtml;
    const contentState = ContentState.createFromBlockArray(contentBlocks, entityMap);
    const editorStateDraft = EditorState.createWithContent(contentState);
    setEditorState(editorStateDraft);
  }, []);

  /**
   * The function takes in an editorState and sets the editorState to the editorState that was passed in. Then, it takes the current content of the
   * editorState and converts it to HTML. Then, it takes the HTML and changes the value of the target to the name of the editor and the value of the
   * description.
   * @param editorState - The current state of the editor.
   */
  const onEditorStateChange = (editorState) => {
    setEditorState(editorState);
    const description = draftToHtml(convertToRaw(editorState.getCurrentContent()));
    changeValue({ target: { name: name, value: description } });
  };

  const [editorState, setEditorState] = useState(EditorState.createEmpty());
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
            className="form-control"
            editorState={editorState}
            toolbarClassName="toolbarClassName"
            wrapperClassName="wrapperClassName"
            editorClassName="editorClassName"
            name={name}
            onEditorStateChange={onEditorStateChange}
            // toolbar={{
            //   options: ["inline", "blockType"],
            // }}
          />
        </div>
      </div>
    </div>
  );
}

export default TextArea;
