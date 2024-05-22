import { useEffect, useState, Fragment } from "react";
import { useNavigate, Link } from "react-router-dom";

import { DmpApi } from "../../api.js";
import { truncateText } from "../../utils.js";
import { DmpModel, getDmp } from "../../models.js";



import TextInput from "../../components/text-input/textInput.js";
import LookupField from "../../components/lookup-field.js";
import Spinner from "../../components/spinner";
import "./dashboard.scss";

let DMP_ID_REGEX = /\/dmps\/([^/]+\/[^/]+)/; //For local development and stage

if (window.location.hostname === 'dmptool.org' || (process.env.NODE_ENV && process.env.NODE_ENV === 'production')) {
  DMP_ID_REGEX = /[^/]+\/([^/]+\/[^/]+)/
}

function Dashboard() {
  const [projects, setProjects] = useState([]);
  const [previewDmp, setPreviewDmp] = useState({});
  const [user, setUser] = useState({
    givenname: "",
    surname: "",
  });

  let navigate = useNavigate();

  const [show, setShow] = useState(false);
  const [showFilterDrawer, setShowFilterDrawer] = useState(false);
  const [working, setWorking] = useState(false);
  const dialog = document.querySelector("#filter-modal");

  function handleFilterDrawerClose(id) {
    dialog.close();
    setShowFilterDrawer(false);
    return false;
  }

  function handleFilterDrawerOpen(id) {
    dialog.showModal();
    setShowFilterDrawer(true);
    document.getElementById("filter_title").focus();
    return false;
  }

  function handleQuickViewOpen(id) {
    setWorking(true);
    console.log("Open Modal; Api Load data: ", id);

    const selectedProject = projects.find(project => project.id === id);
    if (selectedProject) {
      //setPreviewDmp(selectedProject);
      setShow(true);
      getDmp(selectedProject.id).then((initial) => {
        console.log("DMP Data: ", initial);
        setPreviewDmp(initial);
        setWorking(false);
      });
    }
    return false;
  }

  const [filter_title, setFilter_Title] = useState("");
  const [filter_funder, setFilter_Funder] = useState("");
  const [filter_grantId, setFilter_GrantId] = useState("");
  const [filter_dmpId, setFilter_DmpId] = useState("");

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    setFilter_Title(params.get("title") || "");
    setFilter_Funder(params.get("funder") || "");
    setFilter_GrantId(params.get("grant_id") || "");
    setFilter_DmpId(params.get("dmp_id") || "");
  }, [window.location.search]);

  function checkFiltersApplied() {
    const filters = [filter_title, filter_funder, filter_grantId, filter_dmpId];
    const appliedFilters = filters.filter((filter) => filter !== "");
    return appliedFilters.length;
  }

  function handleClearAll(e) {
    e.preventDefault();
    setFilter_Title("");
    setFilter_Funder("");
    setFilter_GrantId("");
    setFilter_DmpId("");
    return false;
  }

  useEffect(() => {
    let api = new DmpApi();
    setWorking(true);

    fetch(api.getPath("/me"), api.getOptions())
      .then((resp) => {
        api.handleResponse(resp);
        return resp.json();
      })
      .then((data) => {
        setUser(data.items[0]);
      });

    // Fetch the work in progress DMPs for the currently logged in user
    fetch(api.getPath("/drafts", window.location.search), api.getOptions())
      .then((resp) => {
        api.handleResponse(resp);
        return resp.json();
      })
      .then((data) => {
        const dmpModels = data.items.map((item) => new DmpModel(item.dmp));
        setProjects(dmpModels);
        setWorking(false);
      });
  }, []);

  return (
    <div id="Dashboard">
      <div className="dmpui-heading with-action-button">
        <div>
          <h1>Pilot Upload Projects</h1>
          <p>Projects created via the upload of an existing DMP are listed in the table below, including their registration status and DOI (when generated).</p>
        </div>
        <div>
          <button
            className="primary"
            onClick={() => navigate("/dashboard/dmp/new")}
          >
            Add Plan
          </button>
        </div>
      </div>

      <div className="plan-steps">
        <div className="plan-step">
          <div className="filter-tags">
            <p className="filter-heading sr-only">Filter:</p>
            <button
              className="button filter-button"
              onClick={() => handleFilterDrawerOpen()}
            >
              Filter DMPs
              {checkFiltersApplied() > 0 && (
                <span
                  className="filter-count"
                  title={checkFiltersApplied() + " filters applied"}
                >
                  {checkFiltersApplied()}
                </span>
              )}
            </button>

            {checkFiltersApplied() > 0 && (
              <a href="/dashboard" className="filter-clear-all-button">
                Clear Filters
              </a>
            )}
          </div>
        </div>


        <div className="table-container">
          <div className="table-wrapper">
            {working ? (
              <Spinner isActive={working} message="Fetching DMPs ..." className="empty-list" />
            ) : projects.length > 0 ? (
              <table className="dashboard-table">
                <thead>
                  <tr>
                    <th scope="col" className="table-header-name data-heading">
                      Project Name
                    </th>

                    <th scope="col" className="table-header-name data-heading text-center no-wrap">
                      DMP PDF
                    </th>

                    <th scope="col" className="table-header-name data-heading">
                      Funder
                    </th>

                    <th scope="col" className="table-header-name data-heading">
                      Last Edited
                    </th>

                    <th scope="col" className="table-header-name data-heading">
                      DMP ID
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
                  {projects.map((dmp) => {

                    const dmpId = dmp.landingPageUrl ? dmp.landingPageUrl.match(DMP_ID_REGEX)[1] || [] : null;

                    return (
                      <Fragment key={dmp.id}>
                        <tr key={dmp.id}>
                          <td
                            className="table-data-name table-data-title"
                            data-colname="title"
                          >
                            <Link
                              title={dmp.title}
                              to={`/dashboard/dmp/${dmp.id}`}
                            >
                              {truncateText(dmp.title, 50)}
                            </Link>

                            <a
                              className="preview-button"
                              title={"Preview plan " + dmp.title}
                              aria-label={"Preview plan " + dmp.title}
                              onClick={(e) => handleQuickViewOpen(dmp.id) }
                            >
                              <svg
                                xmlns="http://www.w3.org/2000/svg"
                                height="18"
                                style={{ top: "3px", position: "relative" }}
                                viewBox="0 -960 960 960"
                                width="18"
                              >
                                <path d="M433-344v-272L297-480l136 136ZM180-120q-24.75 0-42.375-17.625T120-180v-600q0-24.75 17.625-42.375T180-840h600q24.75 0 42.375 17.625T840-780v600q0 24.75-17.625 42.375T780-120H180Zm453-60h147v-600H633v600Zm-60 0v-600H180v600h393Zm60 0h147-147Z" />
                              </svg>
                              <span className="screen-reader-text">
                                Open Plan Preview
                              </span>
                            </a>

                            <div className="d-block table-data-pi">
                              {dmp.contributors
                                ? dmp.contributors.items.map((item, index) => (
                                  <Fragment key={index}>
                                    {item.roles &&
                                      item.roles.filter(str => str.includes("investigation")) && (
                                        <span>
                                          PI: {truncateText(item.name, 80)}
                                        </span>
                                      )}
                                  </Fragment>
                                ))
                                : ""}

                              {dmp?.modifications?.items?.length > 0 && (
                                <span class="related-works-details">
                                  {dmp.modifications.items.length} related work{dmp.modifications.items.length > 1 ? 's' : ''}
                                </span>
                              )}

                            </div>
                          </td>


                          <td className="table-data-name text-center" data-colname="pdf">
                            {dmp.narrativeUrl &&
                              <a target="_blank" className="has-new-window-popup-info" href={dmp.narrativeUrl}>
                                <i className="fas fa-file-pdf" aria-hidden="true"></i>
                                <em className="sr-only">(opens as a .pdf document in a new window)</em>
                                <span className="new-window-popup-info">Opens in a new window</span>
                              </a>
                            }
                          </td>


                          <td className="table-data-name" data-colname="funder">
                            {dmp.funding.acronym ? (
                              <span title={dmp.funding.name}>
                                {dmp.funding.acronym}
                              </span>
                            ) : dmp.funding.name ? (
                              <span title={dmp.funding.name}>
                                {truncateText(dmp.funding.name, 50)}
                              </span>
                            ) : (
                              "None"
                            )}


                          </td>
                          <td
                            className="table-data-date"
                            data-colname="last_edited"
                          >
                            {dmp?.modified ? dmp?.modified : dmp?.created}
                          </td>
                          <td className="table-data-date" data-colname="dmp_id">
                            {dmp.landingPageUrl &&
                              <a target="_blank" className="has-new-window-popup-info" href={dmp.landingPageUrl} title="dmp data">
                                {dmpId}
                                <em className="sr-only">(opens dmp data in a new window</em>
                                <span className="new-window-popup-info">Opens in new window</span>
                              </a>
                            }
                          </td>
                          <td
                            className={"table-data-name status-" + dmp.status[0]}
                            data-colname="status"
                          >
                            {dmp.status[1]}
                          </td>
                          <td
                            className="table-data-name table-data-actions"
                            data-colname="actions"
                          >
                            {dmp.status[1] === "Complete" ? (
                              <Link
                                className="edit-button"
                                to={`/dashboard/dmp/${dmp.id}`}
                              >
                                Complete
                              </Link>
                            ) : (
                              <Link
                                className="edit-button"
                                to={`/dashboard/dmp/${dmp.id}`}
                              >
                                Update
                                <span className={"action-required hidden"}></span>
                              </Link>
                            )}
                          </td>
                        </tr>
                      </Fragment>
                    )
                  })}
                </tbody>
              </table>
            ) : (
              <div className="no-dmp-message mt-5">
                <h3>There are no DMP results found</h3>
                <p>
                  No DMPs were found that match your search criteria. Please
                  broaden your search and try again.
                </p>
              </div>
            )}
          </div>
        </div>
      </div>

      <div
        id="quick-view-modal"
        className={show ? "show" : ""}
        aria-modal="true"
        role="dialog"
        aria-labelledby="preview-heading"
        onClose={() => setShow(false)}
      >
        <div id="quick-view-backdrop">
          <div id="quick-view-view">
            <div className="quick-view-text-cont">
              {working ? (
                <div className="quick-view-loader text-center">
                  <Spinner isActive={working} message="Loading preview ..." className="empty-list" />
                </div>
              ) : previewDmp ? (
                <div>

                  <h3 className="h2" id="preview-heading">
                    <div>{previewDmp.title}</div>

                    <div className="form-actions">
                      <button type="button" aria-label="Close" onClick={() => setShow(false)}>
                        X
                      </button>
                    </div>
                  </h3>

                  <h4>Funder</h4>
                  {previewDmp?.funding?.name ? <p>{previewDmp.funding.name}</p> : <p>None</p>}

                  <h4>DMP ID</h4>
                  {previewDmp?.draftId !== previewDmp?.id ? <p>{previewDmp.id?.replace(/_/g, '/')}</p> : <p>Not Set</p>}

                  {previewDmp?.funding?.grantId?.identifier && (
                    <>
                      <h4>Grant ID</h4>
                      <p class="preview-grant">{previewDmp.funding?.grantId?.identifier}</p>
                    </>
                  )}

                  {previewDmp?.project && (previewDmp.project.start || previewDmp.project.end) && (
                    <>
                      <h4>Project Dates</h4>
                      <p>
                        {`Start: ${previewDmp.project.start?.format("YYYY-MM-DD") !== 'Invalid date' ? previewDmp.project.start.format("YYYY-MM-DD") : 'Not set'}, `}
                        {`End: ${previewDmp.project.end?.format("YYYY-MM-DD") !== 'Invalid date' ? previewDmp.project.end.format("YYYY-MM-DD ") : 'Not set '}`}
                      </p>
                    </>
                  )}

                  <h4>Lead PI(s)</h4>
                  {previewDmp?.contributors?.items?.length > 0 ? (
                    <p>
                      {previewDmp.contributors.items.reduce((acc, item) => {
                        if (item.roles?.some(role => role.includes("investigation"))) {
                          acc.push(truncateText(item.name, 80)); // Push the name if it matches the role
                        }
                        return acc;
                      }, []).join(", ") || "Not Set"}
                    </p>
                  ) : (
                    <p>Not Set</p>
                  )}

                  {previewDmp?.modifications?.items?.length > 0 && (

                    <>
                      <h4>Related Works</h4>
                      <p>
                        {previewDmp.modifications.items?.length} related work{previewDmp.modifications.items.length > 1 ? 's' : ''}
                      </p>
                    </>
                  )}

                  {previewDmp?.dataset?.items?.length > 0 && (
                    <>
                      <h4>Repositories</h4>
                      <p>
                        {previewDmp.dataset.items.map(item => item.repository.title).join(", ") || "Not Set"}
                      </p>
                    </>
                  )}


                  <h4>Is Public?</h4>
                  <p>
                    {previewDmp.privacy === "public" ? "Yes" : "No"}
                  </p>

                  <h4>Last Edited</h4>
                  <p>
                    {previewDmp.modified}
                  </p>


                </div>

              ) : "Could not load..."}


            </div>



            {working ? (
              <div></div>
            ) : previewDmp ? (
              <div className="form-actions ">
                <button type="button" className="primary" onClick={() => navigate(`/dashboard/dmp/${previewDmp.id}`)}>
                  Update
                </button>
                <button type="button" onClick={() => setShow(false)}>
                  Close
                </button>
              </div>
            ) : null}



          </div>
        </div>
      </div >

      <dialog
        id="filter-modal"
        aria-modal="true"
        role="dialog"
        aria-labelledby="filter-heading"

        className={showFilterDrawer ? "show" : ""}
        onClose={() => setShowFilterDrawer(false)}
      >
        <div id="filter-view-backdrop">
          <div id="filter-view">
            <form
              method="get"
              encType="multipart/form-data"
              action="/dashboard"
            >
              <div className="quick-view-text-cont">
                <h3 id="filter-heading">Filters</h3>
                <div className="dmpui-form-col">
                  <TextInput
                    label="Title"
                    type="text"
                    name="title"
                    id="filter_title"
                    placeholder=""
                    inputValue={filter_title}
                    onChange={(e) => setFilter_Title(e.target.value)}
                    help="Search for the specified text within the project title and abstract"
                  />

                  <LookupField
                    label="Funder"
                    name="funder"
                    id="filter_funder"
                    endpoint="funders"
                    placeholder=""
                    help="Search for the name of the funder"
                    inputValue={filter_funder}
                    onChange={(e) => setFilter_Funder(e.target.value)}
                    error=""
                  />

                  <TextInput
                    label="Grant ID"
                    type="text"
                    name="grant_id"
                    id="filter_grant_id"
                    placeholder=""
                    value={filter_grantId}
                    onChange={(e) => setFilter_GrantId(e.target.value)}
                    help="Search for the Grant ID"
                  />
                  <TextInput
                    label="DMP ID"
                    type="text"
                    name="dmp_id"
                    id="filter_dmp_id"
                    placeholder=""
                    value={filter_dmpId}
                    onChange={(e) => setFilter_DmpId(e.target.value)}
                    help="Search for the name of the DMP ID"
                  />
                </div>
              </div>

              {checkFiltersApplied() > 0 && (
                <div>
                  <a href="#" onClick={handleClearAll}>
                    Clear All Filters
                  </a>
                </div>
              )}
              <div className="form-actions">
                <button type="submit" className="primary">
                  Filter
                </button>
                <button
                  type="button"
                  onClick={() => handleFilterDrawerClose(false)}
                >
                  Close
                </button>
              </div>
            </form>
          </div>
        </div>
      </dialog>
    </div >
  );
}

export default Dashboard;
