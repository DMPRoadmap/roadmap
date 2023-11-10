import {
  useEffect,
  useState,
  Fragment
} from "react";
import { useNavigate, useParams } from "react-router-dom";

import {
  DmpModel,
  getDmp,
  saveDmp,
  RelatedWork,
} from "../../../models.js";

import { truncateText } from "../../../utils.js";


import TextInput from "../../../components/text-input/textInput.js";
import TextArea from "../../../components/textarea/textArea.js";
import Select from "../../../components/select/select.js";
import RadioButton from "../../../components/radio/radio.js";
import LookupField from "../../../components/lookup-field.js";
import Spinner from "../../../components/spinner.js";

import "./relatedworks.scss";


function RelatedWorksPage() {
  let navigate = useNavigate();

  const { dmpId } = useParams();
  const [dmp, setDmp] = useState(null);
  const [relatedWorks, setRelatedWorks] = useState([]);
  const [filterArgs, setFilterArgs] = useState({status: ""});
  const [editIndex, setEditIndex] = useState(null);
  const [relatedWrk, setRelatedWrk] = useState(new RelatedWork({}));

  useEffect(() => {
    getDmp(dmpId).then(initial => {
      setDmp(initial);
    });
  }, [dmpId]);


  useEffect(() => {
    if (!dmp) return;
    if (!dmp.hasRelatedWorks()) return;

    let newRelated = [];

    dmp.modifications
        .items
        .forEach(mod => mod.relatedWorks.items.forEach(rw => {
          newRelated.push(rw);
        }));

    if (filterArgs.status !== "") {
      newRelated = newRelated.filter(rw => rw.status === filterArgs.status);
    }

    setRelatedWorks(newRelated);
  }, [filterArgs, dmp]);


  function handleStatusChange(ev) {
    ev.preventDefault();
    const { name, value } = ev.target;

    switch (name) {
      case "filter_pending":
        setFilterArgs({...filterArgs, status: "pending"});
        break;

      case "filter_approved":
        setFilterArgs({...filterArgs, status: "approved"});
        break;

      case "filter_rejected":
        setFilterArgs({...filterArgs, status: "rejected"});
        break;
    }
  }

  function handleChange(ev) {
    const { name, value } = ev.target;

    /*
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
        if (ev.data) {
          newObj.repository = new DataRepository(ev.data);
          // NOTE:: The lookup data returns the repository name as "name",
          // but the DMP saves the repo name as "title".
          newObj.repository.title = ev.data.name;
          setDataObj(newObj);
        } else {
          // Only reset /all/ the data if the repo was previously locked
          if (newObj.repository.isLocked) {
            newObj.repository = new DataRepository({});
          }
          newObj.repository.title = value;
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
    */
  }


  function handleModalOpen(ev) {
    ev.preventDefault();

    const index = ev.target.value;

    if ((index !== "") && (typeof index !== "undefined")) {
      let newObj = relatedWorks[index];
      setRelatedWrk(newObj);
    }

    document.getElementById("outputsModal").showModal();
  }


  function handleSaveModal(ev) {
    ev.preventDefault();
    /*
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
        }
        */
    document.getElementById("outputsModal").close();
  }


  function closeModal(ev) {
    if (ev) ev.preventDefault();
    setRelatedWrk(new RelatedWork({}));
    document.getElementById("outputsModal").close();
  }


  async function handleSave(ev) {
    /*
    ev.preventDefault();
    saveDmp(dmp).then(() => {
      navigate(-1);
    });
    */
  }


  return (
    <>
      {!dmp ? (
        <Spinner isActive={true} message="Fetching related works…" className="page-loader" />
      ) : (
        <div id="RelatedWorks">
          <div className="dmpui-heading">
            <h1>Related works</h1>
          </div>

          <p>This is a list of works that we think might be
            related to your project based on its Title, Abstract,
            or some other piece of metadata. Linking related
            works to your project can help other researchers.</p>

          <p>You can read more about a work by clicking Review.
            Mark each work as Related or Not Related. You can
            optionally note if a work is related to one of your
            planned Research Outputs.</p>

          <p>Filter the list to show works you've previously marked
            as Related, or to return to the list of Unrelated works. </p>

          <div className="plan-steps">
            <div className="plan-step">
              <div className="filter-container">
                <div className="filter-status">
                  <p className="filter-heading"><strong>Status</strong></p>
                  <div className="filter-quicklinks">
                    <a href="?status=pending" name="filter_pending" onClick={handleStatusChange}>Pending Review</a>
                    <a href="?status=approved" name="filter_approved" onClick={handleStatusChange}>Related</a>
                    <a href="?status=rejected" name="filter_rejected" onClick={handleStatusChange}>Rejected</a>
                  </div>
                </div>
              </div>
            </div>
            <div className="table-container">
              <div className="table-wrapper">
                {relatedWorks ? (
                  <table className="dashboard-table">
                    <thead>
                      <tr>
                        <th scope="col" className="table-header-name data-heading">
                          Citation
                        </th>

                        <th scope="col" className="table-header-name data-heading">
                          Confidence
                        </th>

                        <th scope="col" className="table-header-name data-heading">
                          Date Found
                        </th>

                        <th scope="col" className="table-header-name data-heading">
                          Status
                        </th>

                        <th scope="col" className="table-header-name data-heading">
                          Actions
                        </th>
                      </tr>
                    </thead>
                    <tbody className="table-body">
                      {relatedWorks ? relatedWorks.map((rw, index) => (
                        <Fragment key={index}>
                          <tr>
                            <td
                              className="table-data-name table-data-title"
                              data-colname="title"
                            >
                              {rw.citation ? (
                                <span className="truncated-text"
                                  aria-label="{rw.citation}"
                                  title={rw.citation}
                                >
                                  {truncateText(rw.citation, 180)}
                                </span>
                              ) : (
                                <span className="text-muted">
                                  The Citation for this work is not available. Review for more information.
                                </span>
                              )}
                            </td>
                            <td
                              className="table-data-name table-data-confidence"
                              data-colname="confidence"
                            >
                              {rw.confidence}
                            </td>
                            <td
                              className="table-data-name table-data-date"
                              data-colname="last_edited"
                            >
                              {rw.dateFound}
                            </td>
                            <td
                              className="table-data-name table-data-status"
                              data-colname="status"
                            >
                              {rw.status}
                            </td>
                            <td
                              className="table-data-name table-data-actions"
                              data-colname="actions"
                            >
                              <button value={index} onClick={handleModalOpen}>
                                Review
                              </button>
                            </td>
                          </tr>
                        </Fragment>
                      )) : null}
                    </tbody>
                  </table>
                ) : (
                  <div className="no-dmp-message mt-5">
                    <h3>There are no related works found</h3>
                    <p>
                      No related works were found. Please
                      check again soon.
                    </p>
                  </div>
                )}
              </div>
            </div>
          </div>

          <dialog id="outputsModal">
            <form method="post" encType="multipart/form-data" onSubmit={handleSaveModal}>
              <div className="form-modal-wrapper">
                <div className="dmpui-form-cols">
                  <div className="dmpui-form-col">

                    <h4>
                      Review related work
                    </h4>

                    <p>
                      Review the information about this potentially related work below, and then approve it as related or reject it as unrelated.
                    </p>
                  </div>
                </div>

                <div className="dmpui-form-cols">
                  <div className="dmpui-form-col">

                    <div className="dmpui-field-group">
                      <label className="dmpui-field-label">DOI</label>

                      {relatedWrk.doi ? (
                        <p>
                          <a href={"http://doi.org/" + relatedWrk.doi} target="_blank" rel="noopener noreferrer">
                            {relatedWrk.doi}

                            <svg xmlns="http://www.w3.org/2000/svg"
                              style={{ top: "3px", position: "relative", marginLeft: "5px" }}
                              width="1rem" height="1rem" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor" className="w-6 h-6">
                              <path strokeLinecap="round" strokeLinejoin="round" d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" />
                            </svg>
                          </a>
                        </p>
                      ) : (
                        <p className="text-muted">
                          No DOI
                        </p>
                      )}
                    </div>

                    <div className="dmpui-field-group">
                      <label className="dmpui-field-label">
                        Citation
                      </label>
                      {relatedWrk.citation ? (
                        <p>{relatedWrk.citation}</p>
                      ) : (
                        <p className="text-muted">
                          The Citation for this work is not available.
                        </p>
                      )}
                    </div>

                    <div className="dmpui-field-group">
                      <label className="dmpui-field-label">Provenance</label>
                      {relatedWrk.provenance ? (
                        <p>{relatedWrk.provenance}</p>
                      ) : (
                        <p className="text-muted">
                          provenance is not available
                        </p>
                      )}
                    </div>

                    <div className="dmpui-field-group">
                      <label className="dmpui-field-label">
                        Confidence
                      </label>
                      {relatedWrk.confidence ? (
                        <>
                          <p>{relatedWrk.confidence}</p>
                          <p className="dmpui-field-help">{relatedWrk.confidenceReason}</p>
                        </>
                      ) : (
                        <p className="text-muted">
                          Undetermined
                        </p>
                      )}
                    </div>

                    <div className="dmpui-field-group">
                      <label className="dmpui-field-label">
                        Date Found
                      </label>

                      {relatedWrk.dateFound ? (
                        <p>{relatedWrk.dateFound}</p>
                      ) : (
                        <p className="text-muted">
                          Undetermined
                        </p>
                      )}
                    </div>

                    <div className="dmpui-field-group">
                      <label className="dmpui-field-label">
                        Current Status
                      </label>

                      {relatedWrk.status ? (
                        <p>{relatedWrk.status}</p>
                      ) : (
                        <p className="text-muted">
                          Undetermined
                        </p>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              <div className="form-actions ">
                <button type="button" onClick={closeModal}>
                  Cancel
                </button>
                <button type="submit" className="">
                  Mark as Unrelated
                </button>
                <button type="submit" className="primary">
                  Mark as Related
                </button>
              </div>
            </form>
          </dialog>

          <form method="post" encType="multipart/form-data" onSubmit={handleSave}>
            <div className="form-actions ">
              <button type="button" onClick={() => navigate(`/dashboard/dmp/${dmp.id}`)}>
                {dmp.isRegistered ? "Back" : "Cancel"}
              </button>

              <button type="submit" className="primary">
                Save &amp; Continue
              </button>

            </div>
          </form>
        </div>
      )}
    </>
  );
}

export default RelatedWorksPage;
