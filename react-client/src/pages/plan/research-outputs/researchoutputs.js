import {
  useEffect,
  useState,
  Fragment
} from "react";
import { useNavigate, useParams } from "react-router-dom";

import {
  DmpModel,
  DataObject,
  getDraftDmp,
  saveDraftDmp,
} from "../../../models.js";

import TextInput from "../../../components/text-input/textInput.js";
import Select from "../../../components/select/select.js";
import RadioButton from "../../../components/radio/radio";

import "./researchoutputs.scss";


function ResearchOutputs() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});
  const [editIndex, setEditIndex] = useState(null);
  const [dataObj, setDataObj] = useState(new DataObject({}));


  useEffect(() => {
    getDraftDmp(dmpId).then(initial => {
      setDmp(initial);
    });
  }, [dmpId]);


  function handleChange(ev) {
    const {name, value} = ev.target;

    console.log(`Handle Change: ${name}: ${value}`);

    switch (name) {
      case "sensitive_data":
        // setSensitiveData(value);
        dataObj.sensitive = value;
        var newObj = new DataObject(dataObj.getData());
        setDataObj(newObj);
        break;

      case "personal_info":
        // setPersonalInfo(value);
        dataObj.personal = value;
        var newObj = new DataObject(dataObj.getData());
        setDataObj(newObj);
        break;
    }
  }


  // let data = [
  //   {
  //     id: "1",
  //     title: "Figure 1",
  //     personal: "No",
  //     sensitive: "No",
  //     repo: "No",
  //     type: "Image",
  //   },
  //   {
  //     id: "2",
  //     title: "Dataset",
  //     personal: "No",
  //     sensitive: "No",
  //     repo: "No",
  //     type: "Dataset",
  //   },
  //   {
  //     id: "3",
  //     title: "Dateset2",
  //     personal: "No",
  //     sensitive: "No",
  //     repo: "No",
  //     type: "Dataset",
  //   },
  //   {
  //     id: "4",
  //     title: "Demographics",
  //     personal: "yes",
  //     sensitive: "No",
  //     repo: "No",
  //     type: "Dataset",
  //   },
  // ];


  function handleModalOpen(ev) {
    ev.preventDefault();

    const index = ev.target.value;
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


  function handleCancelModal(ev) {
    ev.preventDefault();
    // setContributor(new Contributor({}));
    document.getElementById("outputsModal").close();
  }


  async function handleSave(ev) {
    ev.preventDefault();

    console.log("Save Outputs");
    alert("save Outputs");
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
            <div data-colname="repo">{item.repo}</div>
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

                  <div onChange={handleChange}>
                    <RadioButton
                      label="Yes"
                      name="personal_info"
                      id="_personal_info_yes"
                      value="yes"
                      checked={dataObj.isPersonal}
                    />
                    <RadioButton
                      label="No"
                      name="personal_info"
                      id="_personal_info_no"
                      value="no"
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
                      id="sensitive_data_yes"
                      value="yes"
                      checked={dataObj.isSensitive}
                    />
                    <RadioButton
                      label="No"
                      name="sensitive_data"
                      id="sensitive_data_no"
                      value="no"
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
