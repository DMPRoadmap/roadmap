import { Link, useNavigate, useParams } from "react-router-dom";

import { useContext, useEffect, useState, Fragment } from "react";

import { DmpApi } from "../../../api.js";

// forms
import TextInput from "../../../components/text-input/textInput.js";
import Select from "../../../components/select/select.js";
import RadioButton from "../../../components/radio/radio";
import Modal from "../../../components/modal/modal";
import "./researchoutputs.scss";

function ResearchOutputs() {
  let navigate = useNavigate();
  const [show, setShow] = useState(false);
  const [sensitiveData, setSensitiveData] = useState("no");
  const [personalInfo, setPersonalInfo] = useState("no");
  const [data_type, setData_type] = useState("no");

  let options = {
    audiovisual: "Audiovisual",
    collection: "Collection",
    data_paper: "Data paper",
    dataset: "Dataset",
    event: "Event",
    image: "Image",
    interactive_resource: "Interactive resource",
    model_representation: "Model representation",
    physical_object: "Physical object",
    service: "Service",
    software: "Software",
    sound: "Sound",
    text: "Text",
    workflow: "Workflow",
  };

  let yes_no_list = [
    {
      id: "yes",
      label: "Yes",
    },
    {
      id: "no",
      label: "No",
    },
  ];

  function handleSensitiveDataChange(ev) {
    const { name, value } = ev.target;
    setSensitiveData(value);
  }

  function handlePersonalInfoChange(ev) {
    const { name, value } = ev.target;
    setPersonalInfo(value);
  }

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

    console.log("Save Outputs");
    alert("save Outputs");
    setShow(false);
  }

  function handleModalOpen(id) {
    console.log("Open Modal; Api Load data: ", id);

    setShow(true);
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
              <button value={item.id} onClick={() => handleModalOpen(item.id)}>
                Edit
              </button>
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
                <Select
                  options={options}
                  label="Data type"
                  type="text"
                  required="required"
                  name="data_type"
                  id="data_type"
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
                <div className={"dmpui-field-group"}>
                  <label className="dmpui-field-label">
                    May contain personally identifiable information?
                  </label>

                  <div onChange={handlePersonalInfoChange}>
                    {yes_no_list.map((item) => (
                      <Fragment key={item.id}>
                        <RadioButton
                          label={item.label}
                          name="personal_info"
                          id={"personal_info_" + item.id}
                          inputValue={item.id}
                          checked={personalInfo === item.id}
                        />
                      </Fragment>
                    ))}
                  </div>
                </div>
              </div>

              <div className="dmpui-form-col">
                <div className={"dmpui-field-group"}>
                  <label className="dmpui-field-label">
                    May contain sensitive data?
                  </label>

                  <div onChange={handleSensitiveDataChange}>
                    {yes_no_list.map((item) => (
                      <Fragment key={item.id}>
                        <RadioButton
                          label={item.label}
                          name="sensitive_data"
                          id={"sensitive_data_" + item.id}
                          inputValue={item.id}
                          checked={sensitiveData === item.id}
                        />
                      </Fragment>
                    ))}
                  </div>
                </div>
              </div>
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
