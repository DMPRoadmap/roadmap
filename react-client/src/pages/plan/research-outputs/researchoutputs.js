import {
  useEffect,
  useState,
  Fragment
} from "react";
import { useNavigate, useParams } from "react-router-dom";

import {
  DmpModel,
  DataObject,
  DataRepository,
  getDraftDmp,
  saveDraftDmp,
  getOutputTypes
} from "../../../models.js";

import TextInput from "../../../components/text-input/textInput.js";
import TextArea from "../../../components/textarea/textArea.js";
import Select from "../../../components/select/select.js";
import RadioButton from "../../../components/radio/radio";
import LookupField from "../../../components/lookup-field.js";

import "./researchoutputs.scss";


function ResearchOutputs() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});
  const [outputTypes, setOutputTypes] = useState({});
  const [editIndex, setEditIndex] = useState(null);
  const [dataObj, setDataObj] = useState(new DataObject({}));


  useEffect(() => {
    getDraftDmp(dmpId).then(initial => {
      setDmp(initial);
      console.log("Initial DMP");
      console.log(initial);
    });

    getOutputTypes().then((data) => {
      console.log(data);
      let typesMap = data.map(t => {
        console.log(t);
        return t;
      });
      setOutputTypes(data);
    });
  }, [dmpId]);


  function handleChange(ev) {
    const {name, value} = ev.target;

    console.log(`Handle Change: ${name}: ${value}`);

    switch (name) {
      case "personal_info":
        var newObj = new DataObject(dataObj.getData());
        newObj.personal = value;
        setDataObj(newObj);
        break;

      case "sensitive_data":
        var newObj = new DataObject(dataObj.getData());
        newObj.sensitive = value;
        setDataObj(newObj);
        break;

      case "repository":
        if (ev.data) {
          let newObj = new DataObject(dataObj.getData());
          newObj.repository = new DataRepository(ev.data);
          setDataObj(newObj);
        } else {
          // TODO: Set the repository name, but we need extra fields here
        }
        break;
    }
  }


  function handleModalOpen(ev) {
    ev.preventDefault();

    const index = ev.target.value;
    console.log('What is the index?');
    console.log(editIndex);
    console.log(typeof editIndex);
    if ((index !== "") && (typeof index !== "undefined") ) {
      setEditIndex(index);
      let newObj = dmp.dataset.get(index);
      setDataObj(newObj);
    } else {
      setEditIndex(null);
      setDataObj(new DataObject({}));
    }

    document.getElementById("outputsModal").showModal();
  }


  function handleSaveModal(ev) {
    ev.preventDefault();
    const data = new FormData(ev.target);
    dataObj.title = data.get("title");

    // TODO: Add the Type

    // NOTE: Repository should already be set.

    if (editIndex === null) {
      dmp.dataset.add(dataObj);
    } else {
      dmp.dataset.update(editIndex, dataObj);
    }
    let newDmp = new DmpModel(dmp.getData());
    setDmp(newDmp);

    document.getElementById("outputsModal").close();
  }


  function handleCancelModal(ev) {
    ev.preventDefault();
    setDataObj(new DataObject({}));
    document.getElementById("outputsModal").close();
  }


  async function handleSave(ev) {
    ev.preventDefault();
    saveDraftDMP(dmp).then(() => {
      navigate(-1);
    });
  }


  return (
    <div id="ResearchOutputs">
      <div className="dmpui-heading">
        <h1>Research Outputs</h1>
      </div>

      <p>Add or edit research outputs to your data management plan.</p>

      <div className="dmpdui-top-actions">
        <div>
          <button className="secondary" onClick={handleModalOpen}>
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

        {dmp.dataset ? dmp.dataset.items.map((item, index) => (
          <Fragment key={index}>
            <div data-colname="name">{item.title}</div>
            <div data-colname="personal">{item.personal}</div>
            <div data-colname="sensitive">{item.sensitive}</div>
            <div data-colname="repo">{item.repository.url}</div>
            <div data-colname="datatype">{item.type}</div>
            <div data-colname="actions">
              <button value={index} onClick={handleModalOpen}>
                Edit
              </button>
            </div>
          </Fragment>
        )): ""}
      </div>

      <dialog id="outputsModal">
        <form method="post" enctype="multipart/form-data" onSubmit={handleSaveModal}>
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
                  options={DataObject.dataTypes}
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
                <h3>Repository</h3>
                <LookupField
                  label="Name"
                  name="repository"
                  id="idRepository"
                  endpoint="repositories"
                  placeholder="Search ..."
                  help="Search for the repository."
                  inputValue={dataObj.repository.name}
                  onChange={handleChange}
                />

                <TextArea
                  label="Description"
                  type="text"
                  inputValue={dataObj.repository.description}
                  onChange={handleChange}
                  name="repository_description"
                  id="idRepositoryDescription"
                  disabled={dataObj.repository.isLocked}
                />

                <TextInput
                  label="URL"
                  type="text"
                  required=""
                  name="repository_url"
                  id="idRepositoryURL"
                  inputValue={dataObj.repository.url}
                  onChange={handleChange}
                  disabled={dataObj.repository.isLocked}
                />
              </div>
            </div>

            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                <div className={"dmpui-field-group"}>
                  <label className="dmpui-field-label">
                    May contain personally identifiable information?
                  </label>

                  <div onChange={handleChange}>
                    <RadioButton
                      label="Yes"
                      name="personal_info"
                      id="idPI_yes"
                      inputValue="yes"
                      checked={dataObj.isPersonal}
                    />
                    <RadioButton
                      label="No"
                      name="personal_info"
                      id="idPI_no"
                      inputValue="no"
                      checked={!dataObj.isPersonal}
                    />
                  </div>
                </div>
              </div>

              <div className="dmpui-form-col">
                <div className={"dmpui-field-group"}>
                  <label className="dmpui-field-label">
                    May contain sensitive data?
                  </label>

                  <div onChange={handleChange}>
                    <RadioButton
                      label="Yes"
                      name="sensitive_data"
                      id="idSD_yes"
                      inputValue="yes"
                      checked={dataObj.isSensitive}
                    />
                    <RadioButton
                      label="No"
                      name="sensitive_data"
                      id="idSD_no"
                      inputValue="no"
                      checked={!dataObj.isSensitive}
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="form-actions ">
            <button type="button" onClick={handleCancelModal}>
              Cancel
            </button>
            <button type="submit" className="primary">
              {(editIndex === null) ? "Add" : "Update"}
            </button>
          </div>
        </form>
      </dialog>


      <form method="post" enctype="multipart/form-data">
        <div className="form-actions ">
          <button type="button" onClick={handleSave}>
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
