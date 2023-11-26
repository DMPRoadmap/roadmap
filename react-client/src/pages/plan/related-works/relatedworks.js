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
  const [working, setWorking] = useState(false);

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
    closeModal();
  }

  function updateRWStatus(status) {
    // Update the related work on a specific modifier run
    dmp.modifications.items.forEach((mod) => {
      mod.relatedWorks.items.forEach((rw, rwIndex) => {
        if (rw.doi === relatedWrk.doi) rw.status = status;
      });
    });

    let newDmp = new DmpModel(dmp.getData());

    setDmp(newDmp);
  }

  function handleApprove(ev) {
    ev.preventDefault();

    let rw = new RelatedWork({
      "work_type": relatedWrk.workType,
      "type": relatedWrk.type,
      "descriptor": relatedWrk.descriptor,
      "identifier": relatedWrk.doi,
    });
    dmp.relatedWorks.add(rw);
    updateRWStatus('approved');

    closeModal();
  }


  function handleReject(ev) {
    ev.preventDefault();

    let removeIndex;
    dmp.relatedWorks.items.forEach((rw, i) => {
      if (rw.doi === relatedWrk.doi) removeIndex = i;
    });
    if (removeIndex) dmp.relatedWorks.remove(removeIndex);

    updateRWStatus('rejected');
    closeModal();
  }


  function closeModal(ev) {
    if (ev) ev.preventDefault();
    setRelatedWrk(new RelatedWork({}));
    document.getElementById("outputsModal").close();
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

                    <div className="dmpui-field-group field-status">
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
                <button type="submit" onClick={handleReject} className="">
                  Mark as Unrelated
                </button>
                <button type="submit" onClick={handleApprove} className="primary">
                  Mark as Related
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
                    Save & Continue
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

export default RelatedWorksPage;
