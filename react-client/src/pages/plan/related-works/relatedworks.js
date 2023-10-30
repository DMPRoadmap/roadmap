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
  getRelatedWorkTypes,
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
  const [relatedTypes, setRelatedTypes] = useState({});
  const [editIndex, setEditIndex] = useState(null);
  const [dataObj, setDataObj] = useState([]);

  const RelatedWorks_ToBeReviewed = [
    {
      "id": "1",
      "citation": "Smith, John A. \"The Unexpected Relationship Between Skyscrapers and Sandwiches: A Comprehensive Investigation into Why Tall Buildings Seemingly Have an Affinity for Tuna Melts.\" Journal of Whimsically Extended Architectural Studies 45, no. 2 (2015): 123-145. DOI: 10.1234/jweas.2015.02.123",
      "doi": "10.47366/sabia.v5n1a3",
      "confidence": "High",
      "confidence_reason": "Cited work has same Grant ID as your DMP",
      "status": "To be Reviewed",
      "date_found": "2023-10-04"
    },
    {
      "id": "2",
      "citation": "Lee, Christopher, and Emily Martin. \"Virtual Reality: The Untold Chronicle of How Avatars Organize Underground Disco Parties When Users Are Away.\" Tech Tales and Giggles Journal 12, no. 3 (2020): 210-235. DOI: 10.9101/ttgj.2020.03.210",
      "doi": "10.9101/ttgj.2020.03.210",
      "confidence": "Medium",
      "confidence_reason": "Cited work has same Funder ID as your DMP",
      "status": "To be Reviewed",
      "date_found": "2023-10-01"
    },
    {
      "id": "3",
      "citation": "Patel, Ankit, Sarah O'Connor, and Peter Wang. \"From Nano- Boogies to Micro - Mambos: The Hidden World of Nanobots Who Just Can't Resist a Good Beat.\" Journal of Far-Fetched Medical Phenomena and Dancing Particles 50, no. 6 (2019): 789-812. DOI: 10.1314/jffmpdp.2019.06.789",
      "doi": "10.1314/jffmpdp.2019.06.789",
      "confidence": "High",
      "confidence_reason": "Cited work has same Grant ID as your DMP",
      "status": "To be Reviewed",
      "date_found": "2023-09-27"
    },
    {
      "id": "200",
      "doi": "10.1314/jffmpdp.2019.06.789",
      "citation": "",
      "confidence_reason": "Cited work has same Funder ID as your DMP",
      "confidence": "Medium",
      "status": "To be Reviewed",
      "date_found": "2022-10-01"
    },
  ];
  const RelatedWorks_Related = [
    {
      "id": "1",
      "citation": "Doe, Jane, and Robert Brown. \"Marine Life's Latest Trend: Sunscreen for Fish and Why Crabs Are Opting for Tiny Sunglasses Instead of SPF.\" Laugh Out Loud Environmental Quarterly 32, no. 4 (2018): 567-590. DOI: 10.5678/loleq.2018.04.567",
      "doi": "10.1314/jffmpdp.2019.06.789",
      "confidence": "High",
      "confidence_reason": "Cited work has same Funder ID as your DMP",
      "status": "Reviewed",
      "date_found": "2023-10-04"
    },

  ];
  const RelatedWorks_NotRelated = [
    {
      "id": "100",
      "citation": "Doe, Jane, and Robert Brown. \"Marine Life's Latest Trend: Sunscreen for Fish and Why Crabs Are Opting for Tiny Sunglasses Instead of SPF.\" Laugh Out Loud Environmental Quarterly 32, no. 4 (2018): 567-590. DOI: 10.5678/loleq.2018.04.567",
      "doi": "10.1314/jffmpdp.2019.06.789",
      "confidence": "Low",
      "confidence_reason": "",
      "status": "Not Related",
      "date_found": "2022-10-04"
    },
    {
      "id": "200",
      "citation": "",
      "doi": "10.1314/jffmpdp.2019.06.789",
      "confidence": "Medium",
      "confidence_reason": "Similar Authors",
      "status": "Not Related",
      "date_found": "2022-10-01"
    },

  ];

  const [RelatedWorks, setRelatedWorks] = useState(RelatedWorks_ToBeReviewed);


  useEffect(() => {
    getDmp(dmpId).then(initial => {
      setDmp(initial);
    });

    getRelatedWorkTypes().then((data) => {
      console.log("related types?");
      console.log(data)
      setRelatedTypes(data);
    });
  }, [dmpId]);


  function handleStatusChange(ev) {
    ev.preventDefault();
    const { name, value } = ev.target;

    console.log("name", name);
    switch (name) {
      case "review":
        setRelatedWorks(RelatedWorks_ToBeReviewed);

        break;
      case "related":
        setRelatedWorks(RelatedWorks_Related);

        break;
      case "notrelated":

        setRelatedWorks(RelatedWorks_NotRelated);
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
      let newObj = RelatedWorks[index];
      setDataObj(newObj);
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
    // setDataObj(new DataObject({}));
    document.getElementById("outputsModal").close();
  }

  function handleDeleteOutput(ev) {
    /*
    const index = ev.target.value;
    let obj = dmp.dataset.get(index);
 
    if (confirm(`Are you sure you want to delete the output, ${obj.title}?`)) {
      let newDmp = new DmpModel(dmp.getData());
      newDmp.dataset.remove(index);
      setDmp(newDmp);
    }
    */
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
                    <a href="?status=review" name="review" onClick={handleStatusChange} >To be Reviewed</a>
                    <a href="?status=related" name="related" onClick={handleStatusChange}>Related</a>
                    <a href="?status=notrelated" name="notrelated" onClick={handleStatusChange}>Not Related</a>
                  </div>
                </div>
              </div>
            </div>
            <div className="table-container">
              <div className="table-wrapper">
                {RelatedWorks.length > 0 ? (
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
                      {RelatedWorks ? RelatedWorks.map((item, index) => (
                        <Fragment key={index}>
                          <tr>
                            <td
                              className="table-data-name table-data-title"
                              data-colname="title"
                            >
                              {item.citation ? (
                                <span className="truncated-text"
                                  aria-label="{item.citation}"
                                  title={item.citation}
                                >
                                  {truncateText(item.citation, 180)}

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
                              {item.confidence}
                            </td>
                            <td
                              className="table-data-name table-data-date"
                              data-colname="last_edited"
                            >
                              {item.date_found}
                            </td>
                            <td
                              className="table-data-name table-data-status"
                              data-colname="status"
                            >
                              {item.status}
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



                    <label>
                      DOI
                    </label>

                    {dataObj.doi ? (
                      <p>
                        <a href={"http://doi.org/" + dataObj.doi} target="_blank" rel="noopener noreferrer">
                          {dataObj.doi}

                          <svg xmlns="http://www.w3.org/2000/svg"
                            style={{ top: "3px", position: "relative", marginLeft: "5px" }}
                            width="1rem" height="1rem" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h10.5A2.25 2.25 0 0018 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" />
                          </svg>

                        </a>
                      </p>
                    ) : (
                      <p className="text-muted">
                        No DOI
                      </p>
                    )}


                    <label>
                      Citation
                    </label>

                    {dataObj.citation ? (
                      <p>{dataObj.citation}</p>
                    ) : (
                      <p className="text-muted">
                        The Citation for this work is not available.
                      </p>
                    )}



                    <label>
                      Confidence
                    </label>

                    {dataObj.confidence ? (
                      <p>{dataObj.confidence}

                        {dataObj.confidence_reason ? (
                          <span> - {dataObj.confidence_reason}</span>
                        ) : (
                          <span></span>
                        )}
                      </p>
                    ) : (
                      <p className="text-muted">
                        Undetermined
                      </p>
                    )}

                    <label>
                      Date Found
                    </label>

                    {dataObj.date_found ? (
                      <p>{dataObj.date_found}</p>
                    ) : (
                      <p className="text-muted">
                        Undetermined
                      </p>
                    )}

                    <label>
                      Current Status
                    </label>

                    {dataObj.status ? (
                      <p>{dataObj.status}</p>
                    ) : (
                      <p className="text-muted">
                        Undetermined
                      </p>
                    )}

                  </div>
                </div>
                <div className="dmpui-form-cols">
                  <div className="dmpui-form-col">
                    <Select
                      required={true}
                      options={relatedTypes}
                      label="If this work is related to a planned Research Output, select it below"
                      name="associated_output"
                      id="associated_output"
                      inputValue=""
                      help=""
                    />
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
