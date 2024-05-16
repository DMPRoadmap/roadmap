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
    getDmp,
    saveDmp,
    getOutputTypes
} from "../../../models.js";
import { fileSizeUnits } from "../../../utils.js";

import TypeAhead from "../../../components/TypeAhead.jsx";
import TextInput from "../../../components/text-input/textInput.js";
import TextArea from "../../../components/textarea/textArea.js";
import Select from "../../../components/select/select.js";
import RadioButton from "../../../components/radio/radio";
import SizeInput from "../../../components/size-input.js";
import Spinner from "../../../components/spinner";

import "./researchoutputs.scss";


function ResearchOutputs() {
    let navigate = useNavigate();
    let sizeUnits = {};
    fileSizeUnits.forEach(v => sizeUnits[v] = v);

    const { dmpId } = useParams();
    const [dmp, setDmp] = useState(null);
    const [outputTypes, setOutputTypes] = useState({});
    const [editIndex, setEditIndex] = useState(null);
    const [dataObj, setDataObj] = useState(new DataObject({}));
    const [working, setWorking] = useState(false);
    const [otherField, setOtherField] = useState(false);


    useEffect(() => {
        getDmp(dmpId).then(initial => {
            setDmp(initial);
        });

        getOutputTypes().then((data) => {
            setOutputTypes(data);
        });
    }, [dmpId]);


    function handleChange(ev) {
        const { name, value } = ev.target;

        switch (name) {
            case "data_type":
                var newObj = new DataObject(dataObj.getData());
                newObj.type = value;
                setDataObj(newObj);
                break;

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
                var newObj = new DataObject(dataObj.getData());
                newObj.repository = new DataRepository(dataObj.repository.getData());

                if (ev.data) {
                    newObj.repository = new DataRepository(dataObj.repository.getData());
                    newObj.repository.host = ev.data;
                    setDataObj(newObj);
                } else {
                    newObj.repository.title = value;

                    // Reset the host data if the repo was previously locked, but keep
                    // other fields intact
                    if (newObj.repository.isLocked) {
                        newObj.repository.host = {};
                    }
                }
                setDataObj(newObj);
                break;

            case "repository_description":
                var newObj = new DataObject(dataObj.getData());
                newObj.repository.description = value;
                setDataObj(newObj);
                break;

            case "repository_url":
                var newObj = new DataObject(dataObj.getData());
                newObj.repository.url = value;
                setDataObj(newObj);
                break;
        }
    }

    function handleInputChange(ev, name, value) {

        switch (name) {
            case "data_type":
                var newObj = new DataObject(dataObj.getData());
                newObj.type = value;
                setDataObj(newObj);
                break;

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
                var newObj = new DataObject(dataObj.getData());
                newObj.repository = new DataRepository(dataObj.repository.getData());

                if (ev.data) {
                    newObj.repository = new DataRepository(dataObj.repository.getData());
                    newObj.repository.host = ev.data;
                    setDataObj(newObj);
                } else {
                    newObj.repository.title = value;

                    // Reset the host data if the repo was previously locked, but keep
                    // other fields intact
                    if (newObj.repository.isLocked) {
                        newObj.repository.host = {};
                    }
                }
                setDataObj(newObj);
                break;

            case "repository_description":
                var newObj = new DataObject(dataObj.getData());
                newObj.repository.description = value;
                setDataObj(newObj);
                break;

            case "repository_url":
                var newObj = new DataObject(dataObj.getData());
                newObj.repository.url = value;
                setDataObj(newObj);
                break;
        }
    }


    function handleSizeChanged(data) {
        var newObj = new DataObject(dataObj.getData());
        newObj.repository.setSize(data.value, data.unit);
        setDataObj(newObj);
    }


    function handleModalOpen(ev) {
        ev.preventDefault();

        const index = ev.target.value;

        if ((index !== "") && (typeof index !== "undefined")) {
            let newObj = dmp.dataset.get(index);
            setDataObj(newObj);
            setEditIndex(index);
        } else {
            setEditIndex(null);
            setDataObj(new DataObject({}));
        }

        document.getElementById("outputsModal").showModal();
    }


    function handleSaveModal(ev) {
        ev.preventDefault();

        const data = new FormData(ev.target);

        let newObj = new DataObject(dataObj.getData());
        newObj.title = data.get("title");
        newObj.type = data.get("data_type");
        // NOTE: Repository should already be set, because it's handled in the
        // handleChange() function.

        if (newObj.isValid()) {
            if (editIndex === null) {
                dmp.dataset.add(newObj);
            } else {
                dmp.dataset.update(editIndex, newObj);
            }

            let newDmp = new DmpModel(dmp.getData());
            setDmp(newDmp);
            closeModal();
        } else {
            setDataObj(newObj);
            document.getElementById("outputsModal").scroll(0, 0);
            console.log(newObj.errors);

            const errorDiv = document.getElementById('errors');
            errorDiv.focus();
            errorDiv.scrollIntoView();
        }
    }


    function closeModal(ev) {
        if (ev) ev.preventDefault();
        setDataObj(new DataObject({}));
        setOtherField(false);
        document.getElementById("outputsModal").close();
    }

    function handleDeleteOutput(ev) {
        const index = ev.target.value;
        let obj = dmp.dataset.get(index);

        if (confirm(`Are you sure you want to delete the output, ${obj.title}?`)) {
            let newDmp = new DmpModel(dmp.getData());
            newDmp.dataset.remove(index);
            setDmp(newDmp);
        }
    }

    async function handleSave(ev) {
        ev.preventDefault();
        setWorking(true);

        saveDmp(dmp).then(() => {
            navigate(`/dashboard/dmp/${dmp.id}`);
        }).catch((e) => {
            console.log("Error saving DMP");
            console.log(e);
            setWorking(false);
        });
    }

    return (
        <>
            {!dmp ? (
                <Spinner isActive={true} message="Fetching research outputs…" className="page-loader" />
            ) : (
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
                            Proposed Output
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
                            Output type
                        </div>
                        <div className="data-heading" data-colname="actions"></div>

                        {dmp?.dataset?.items ? dmp.dataset.items.map((item, index) => (
                            <Fragment key={index}>
                                <div data-colname="name" id={"Output-" + index}  >{item.title}</div>
                                <div data-colname="personal">{item.personal}</div>
                                <div data-colname="sensitive">{item.sensitive}</div>
                                <div data-colname="repo">{item.repository.title}</div>
                                <div data-colname="datatype">{item.typeDisplay}</div>
                                <div data-colname="actions" className="form-actions">

                                    <button
                                        id={"editOutput-" + index}
                                        aria-labelledby={"editOutput-" + index + " " + "Output-" + index}
                                        value={index}
                                        onClick={handleModalOpen}>
                                        Edit
                                    </button>

                                    <button
                                        id={"editOutput-" + index}
                                        aria-labelledby={"editOutput-" + index + " " + "Output-" + index}
                                        value={index}
                                        onClick={handleDeleteOutput}>
                                        Delete
                                    </button>

                                </div>
                            </Fragment>
                        )) : ""}
                    </div>

                    <dialog id="outputsModal">
                        <form method="post" encType="multipart/form-data" onSubmit={handleSaveModal}>
                            <div className="form-modal-wrapper">
                                <div className="dmpui-form-cols" tabIndex={-1} id="errors">
                                    {dataObj.errors && dataObj.errors.size > 0 && (
                                        <div className="dmpui-form-col" >
                                            <p>There has been some errors</p>
                                            <ul>
                                                {Array.from(dataObj.errors).map(([key, value]) => (
                                                    <li key={key} className="dmpui-field-error">{value}</li>
                                                ))}
                                            </ul>
                                        </div>
                                    )}
                                </div>
                                <div className="dmpui-form-cols">
                                    <div className="dmpui-form-col">
                                        <TextInput
                                            label="Proposed Output"
                                            type="text"
                                            required="required"
                                            name="title"
                                            id="title"
                                            inputValue={dataObj.title}
                                            placeholder=""
                                            help=""
                                            error={dataObj.errors.get("title")}
                                        />
                                    </div>

                                    <div className="dmpui-form-col">
                                        <Select
                                            required={true}
                                            options={outputTypes}
                                            label="Data type"
                                            name="data_type"
                                            id="data_type"
                                            inputValue={dataObj.type}
                                            onChange={handleChange}
                                            error={dataObj.errors.get("type")}
                                            help=""
                                        />
                                    </div>
                                </div>

                                <div className="dmpui-form-cols">
                                    <div className="dmpui-form-col">
                                        <SizeInput
                                            label="Estimated size of data"
                                            name="size"
                                            id="id_size"
                                            unitOptions={sizeUnits}
                                            initialValue={dataObj.repository.size.value}
                                            initialUnit={dataObj.repository.size.unit}
                                            onChange={handleSizeChanged}
                                        />
                                    </div>
                                </div>

                                <div className="dmpui-form-cols">
                                    <div className="dmpui-form-col">
                                        <h3>Repository</h3>

                                        <TypeAhead
                                            label="Name"
                                            name="repository"
                                            id="idRepository"
                                            endpoint="repositories"
                                            placeholder="Search ..."
                                            help="Search for the repository."
                                            inputValue={dataObj.repository.title}
                                            onChange={handleInputChange}
                                            setOtherField={setOtherField}


                                        />
                                    </div>
                                </div>
                                <div className="dmpui-form-cols">
                                    <div className="dmpui-form-col">
                                        {otherField && (
                                            <>
                                                <TextInput
                                                    label="Other Repository Name"
                                                    type="text"
                                                    name="repository_other"
                                                    id="idRepositoryOther"
                                                    onChange={handleChange}
                                                    error={dataObj.errors.get("repo")}
                                                    disabled={dataObj.repository.isLocked}
                                                    hidden={dataObj.repository.isLocked}
                                                    autoFocus={otherField}
                                                />

                                                <TextArea
                                                    label="Other Repository description"
                                                    type="text"
                                                    inputValue={dataObj.repository.description}
                                                    onChange={handleChange}
                                                    name="repository_description"
                                                    id="idRepositoryDescription"
                                                    disabled={dataObj.repository.isLocked}
                                                    hidden={dataObj.repository.isLocked}
                                                />

                                                <TextInput
                                                    label="Other Repository URL"
                                                    type="text"
                                                    required="required"
                                                    name="repository_url"
                                                    id="idRepositoryURL"
                                                    inputValue={dataObj.repository.url}
                                                    onChange={handleChange}
                                                    error={dataObj.errors.get("repo")}
                                                    disabled={dataObj.repository.isLocked}
                                                    hidden={dataObj.repository.isLocked}
                                                />
                                                <p className="dmpui-field-help">(e.g., "https://dataverse.org/")</p>
                                            </>
                                        )

                                        }
                                    </div></div>

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
                                <button type="button" onClick={closeModal}>
                                    Cancel
                                </button>
                                <button type="submit" className="primary">
                                    {(editIndex === null) ? "Add" : "Update"}
                                </button>
                            </div>
                        </form>
                    </dialog>

                    <form method="post" encType="multipart/form-data" onSubmit={handleSave}>
                        <div className="form-actions ">
                            {working ? (
                                <Spinner isActive={working} message="" className="empty-list" />
                            ) : (
                                <>
                                    <button type="button" onClick={() => navigate(`/dashboard/dmp/${dmp.id}`)}>
                                        {dmp.isRegistered ? "Back" : "Cancel"}
                                    </button>
                                    <button type="submit" className="primary">
                                        {dmp.isRegistered ? "Update" : "Save & Continue"}
                                    </button>
                                </>
                            )}
                        </div>
                    </form>
                </div>
            )}
        </>
    );
}

export default ResearchOutputs;
