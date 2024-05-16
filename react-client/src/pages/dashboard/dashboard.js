import { useEffect, useState, Fragment } from "react";
import { useNavigate, Link } from "react-router-dom";

import { DmpApi } from "../../api.js";
import { truncateText } from "../../utils.js";
import { DmpModel, getDmp } from "../../models.js";



import TextInput from "../../components/text-input/textInput.js";
import LookupField from "../../components/lookup-field.js";
import Spinner from "../../components/spinner";
import "./dashboard.scss";
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
          <h1>Uploads</h1>
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

        {/* <div className="plan-step">
        <div className="filter-container">
          <div className="filter-status">
            <p className="filter-heading">Status</p>
            <div className="filter-quicklinks">
              <a href="/?status=all">All</a>
              <a href="/?status=registered">Registered</a>
              <a href="/?status=incomplete">Incomplete</a>
            </div>
          </div>
          <div className="filter-edited">
            <p className="filter-heading">Edited</p>
            <div className="filter-quicklinks">
              <a href="/?status=all">All</a>
              <a href="/?status=lastweek">Last week</a>
              <a href="/?status=lastmonth">Last Month</a>
            </div>
          </div>
          <div className="filter-tags">
            <p className="filter-heading">Filter DMPs</p>
            <button className="button filter-button">Filter</button>
          </div>
          <div className="xcont"></div>
          </div>
          */}

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

                    <th scope="col" className="table-header-name data-heading">
                      Funder
                    </th>

                    <th scope="col" className="table-header-name data-heading">
                      Last Edited
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
                  {projects.map((dmp) => (
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


                          {
                            <a
                              href="#"
                              className="preview-button"
                              aria-label="Open plan preview"
                              onClick={() => handleQuickViewOpen(dmp.id)}
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
                          }
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
                          </div>
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
                  ))}
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

                  <h3 className="h2">
                    {previewDmp.title}
                  </h3>


                  <h4>Funder</h4>
                  {previewDmp && previewDmp.funding && previewDmp.funding.name ? (
                    <p>{previewDmp.funding.name}</p>
                  ) : (
                    <p>None</p>
                  )}


                  <h4> DMP ID </h4>
                  {previewDmp && previewDmp.id && previewDmp.id ? (
                    <p>{previewDmp.id}</p>
                  ) : (
                    <p>Not Set</p>
                  )}

                  {previewDmp && previewDmp.funding && previewDmp.funding.grantId ? (
                    <>
                      <h4>Grant ID</h4>
                      <p>{previewDmp.funding.grantId}</p>
                    </>

                  ) : <></>}




                  {previewDmp && previewDmp.project && (previewDmp.project.start || previewDmp.project.end) ? (
                    <>
                      <h4>Project Dates</h4>
                      <p>

                        {previewDmp.project.start.format("YYYY-MM-DD") ? `Start: ${previewDmp.project.start.format("YYYY-MM-DD")}` : ""}
                        {previewDmp.project.start.format("YYYY-MM-DD") && previewDmp.project.end.format("YYYY-MM-DD") ? " - " : ""}
                        {previewDmp.project.end.format("YYYY-MM-DD") ? `End: ${previewDmp.project.end.format("YYYY-MM-DD")}` : ""}
                      </p>
                    </>

                  ) : <></>}



                  <h4>Lead PI(s)</h4>
                  {previewDmp && previewDmp.contributors && previewDmp.contributors.items.length > 0 ? (
                    <p>
                      {previewDmp.contributors.items.reduce((acc, item) => {
                        if (item.roles && item.roles.some(role => role.includes("investigation"))) {
                          acc.push(truncateText(item.name, 80)); // Push the name if it matches the role
                        }
                        return acc;
                      }, []).join(", ") || "Not Set"}
                    </p>
                  ) : (
                    <p>Not Set</p>
                  )}




                  {previewDmp && previewDmp.relatedWorks && previewDmp.relatedWorks && previewDmp.relatedWorks.items.length > 0 && (
                    <>
                      <h4>Related Works</h4>
                      <p>
                        {previewDmp.relatedWorks.items.length} related works
                      </p>
                    </>
                  )}

                  {previewDmp && previewDmp.dataset && previewDmp.dataset.items ? (
                    <>
                      <h4>Repositories</h4>
                      <p>
                        {previewDmp.dataset.items.map(item => item.repository.title).join(", ") || "Not Set"}
                      </p>
                    </>

                  ) : (
                    <></>
                  )}


                  <h4>Is Public?</h4>
                  <p>
                    {previewDmp.privacy === "public" ? "Yes" : "No"}
                  </p>

                  <h4>Last Updated</h4>
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
