import { Link, useNavigate, useParams } from "react-router-dom";

import { useContext, useEffect, useState, Fragment } from "react";

import { DmpApi } from "../../../api.js";

// forms
import TextInput from "../../../components/text-input/textInput.js";
import TextArea from "../../../components/textarea/textArea.js";
import Modal from "../../../components/modal/modal";
import "./researchoutputs.scss";

function ResearchOutputs() {
  let navigate = useNavigate();
  const [show, setShow] = useState(false);
  let data = [
    {
      id: "1",
      title: "Figure 1",
      personal: "No",
      sensitive: "No",
      repo: "No",
      type: "Image",
    },
    {
      id: "2",
      title: "Dataset",
      personal: "No",
      sensitive: "No",
      repo: "No",
      type: "Dataset",
    },
    {
      id: "3",
      title: "Dateset2",
      personal: "No",
      sensitive: "No",
      repo: "No",
      type: "Dataset",
    },
    {
      id: "4",
      title: "Demographics",
      personal: "yes",
      sensitive: "No",
      repo: "No",
      type: "Dataset",
    },
  ];

  async function handleSave(ev) {
    ev.preventDefault();

    console.log("Save Contributors");
    alert("save contributors");
    setShow(false);
  }

  return (
    <div id="ResearchOutputs">
      <div className="dmpui-heading">
        <h1>Research Outputs</h1>
      </div>

      <p>Add or edit research outputs to your data management plan.</p>

      <div className="dmpdui-top-actions">
        <div>
          <button className="secondary" onClick={() => setShow(true)}>
            Add Output
          </button>
        </div>
      </div>

      <div className="dmpdui-list dmpdui-list-research ">
        <div className="data-heading" data-colname="title">
          Title
        </div>
        <div className="data-heading" data-colname="personal">
          Personal information?
        </div>
        <div className="data-heading" data-colname="sensitive">
          Sensitive data?
        </div>
        <div className="data-heading" data-colname="repo">
          Repository
        </div>
        <div className="data-heading" data-colname="datatype">
          Data type
        </div>
        <div className="data-heading" data-colname="actions"></div>

        {data.map((item) => (
          <Fragment key={item.id}>
            <div data-colname="name">{item.title}</div>
            <div data-colname="personal">{item.personal}</div>
            <div data-colname="sensitive">{item.sensitive}</div>
            <div data-colname="repo">{item.repo}</div>
            <div data-colname="datatype">{item.type}</div>
            <div data-colname="actions">
              <button onClick={() => setShow(true)}>Edit</button>
            </div>
          </Fragment>
        ))}
      </div>

      <Modal title="Add Contributor" onClose={() => setShow(false)} show={show}>
        <form method="post" enctype="multipart/form-data" onSubmit={handleSave}>
          <div className="form-modal-wrapper">
            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                <TextInput
                  label="Title"
                  type="text"
                  required="required"
                  name="title"
                  id="title"
                  placeholder=""
                  help=""
                  error=""
                />
              </div>

              <div className="dmpui-form-col">
                <TextInput
                  label="Data type"
                  type="text"
                  required="required"
                  name="date_type"
                  id="date_type"
                  placeholder=""
                  help=""
                  error=""
                />
              </div>
            </div>

            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                <TextInput
                  label="Repository"
                  type="text"
                  required="required"
                  name="repository"
                  id="repository"
                  placeholder=""
                  help=""
                  error=""
                />
              </div>
            </div>

            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                May contain personally identifiable information?
              </div>

              <div className="dmpui-form-col">May contain sensitive data?</div>
            </div>
          </div>

          <div className="form-actions ">
            <button type="button" onClick={() => setShow(false)}>
              Cancel
            </button>
            <button type="submit" className="primary">
              Save &amp; Continue
            </button>
          </div>
        </form>
      </Modal>

      <form method="post" enctype="multipart/form-data">
        <div className="form-actions ">
          <button type="button" onClick={() => navigate(-1)}>
            Cancel
          </button>
          <button type="submit" className="primary">
            Save &amp; Continue
          </button>
        </div>
      </form>
    </div>
  );
}

export default ResearchOutputs;
