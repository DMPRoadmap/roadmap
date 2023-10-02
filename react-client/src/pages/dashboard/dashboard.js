import { useEffect, useState, Fragment } from "react";
import { useNavigate, Link } from "react-router-dom";

import { DmpApi } from "../../api.js";
import { truncateText } from "../../utils.js";
import { DmpModel } from "../../models.js";

import TextInput from "../../components/text-input/textInput.js";

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

  function handleFilterDrawerOpen(id) {
    setShowFilterDrawer(true);
    return false;
  }

  function handleQuickViewOpen(id) {
    console.log("Open Modal; Api Load data: ", id);
    setShow(true);
    setPreviewDmp(projects.find((dmp) => dmp.draftId === id));
    console.log("Load DMP");
    console.log(previewDmp);
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

  useEffect(() => {
    let api = new DmpApi();

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
      });
  }, []);

  return (
    <div id="Dashboard">
      <p>
        Welcome back {user.givenname} {user.surname}
      </p>
      <p>
        <a href="/plans" className="exit-prototype">
          Back to standard Dashboard
        </a>
      </p>

      <div className="dmpui-heading with-action-button">
        <div>
          <h1>Dashboard</h1>
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
            <p className="filter-heading">Filter DMPs</p>
            <button
              className="button filter-button"
              onClick={() => handleFilterDrawerOpen()}
            >
              Filter
            </button>
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
            <table className="dashboard-table">
              <thead>
                <tr>
                  <th scope="col" className="table-header-name data-heading">
                    <a href="#" className="header-link">
                      Project Name
                    </a>
                  </th>

                  <th scope="col" className="table-header-name data-heading">
                    <a href="#" className="header-link">
                      Funder
                    </a>
                  </th>

                  <th scope="col" className="table-header-name data-heading">
                    <a href="#" className="header-link">
                      Last Edited
                    </a>
                  </th>

                  <th scope="col" className="table-header-name data-heading">
                    <a href="#" className="header-link">
                      Status
                    </a>
                  </th>
                  <th scope="col" className="table-header-name data-heading">
                    <a href="#" className="header-link">
                      Actions
                    </a>
                  </th>
                </tr>
              </thead>
              <tbody className="table-body">
                {projects.map((dmp) => (
                  <Fragment key={dmp.draftId}>
                    <tr key={dmp.draftId}>
                      <td
                        className="table-data-name table-data-title"
                        data-colname="title"
                      >
                        <Link
                          title={dmp.title}
                          to={`/dashboard/dmp/${dmp.draftId}`}
                        >
                          {truncateText(dmp.title, 50)}
                        </Link>

                        {/*
                        <a
                          href="#"
                          title={dmp.title}
                          value={dmp.draftId}
                           onClick={() => handleQuickViewOpen(dmp.draftId)} 
                        >
                          {truncateText(dmp.title, 50)}
                        </a>
            
                        <a
                          href="#"
                          class="preview-button"
                          aria-label="Open plan preview"
                          onClick={() => handleQuickViewOpen(dmp.draftId)}
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
*/}
                        <div className="d-block table-data-pi">
                          {dmp.contributors
                            ? dmp.contributors.items.map((item, index) => (
                                <Fragment key={index}>
                                  {item.roles &&
                                    item.roles.includes("investigation") && (
                                      <span>
                                        PI: {truncateText(item.name, 80)}
                                      </span>
                                    )}
                                </Fragment>
                              ))
                            : ""}

                          {dmp.draftId && dmp.draftId == "XXX" && (
                            <span className={"action-required-text"}>
                              X works need verification
                            </span>
                          )}
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

                        {console.log(dmp)}
                      </td>
                      <td
                        className="table-data-date"
                        data-colname="last_edited"
                      >
                        03-29-2023
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
                        {dmp.draftId && dmp.draftId === "XXX" ? (
                          <Link
                            className="edit-button"
                            to={`/dashboard/dmp/${dmp.draftId}`}
                          >
                            Complete
                          </Link>
                        ) : (
                          <Link
                            className="edit-button"
                            to={`/dashboard/dmp/${dmp.draftId}`}
                          >
                            Update
                            <span className={"action-required"}></span>
                          </Link>
                        )}
                      </td>
                    </tr>
                  </Fragment>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div
        id="quick-view-modal"
        className={show ? "show" : ""}
        title="Add Contributor"
        onClose={() => setShow(false)}
      >
        <div id="quick-view-backdrop">
          <div id="quick-view-view">
            <div className="quick-view-text-cont">
              <h3 className="h2">DMP TITLE</h3>

              <h4>Funder</h4>
              <p>National Institute for Health (NIH)</p>
              <h4>GrantID</h4>
              <p>123456-A</p>
              <h4> DMP ID </h4>
              <p>Not set</p>
              <h4>Dates</h4>
              <p>01-05-2020 - 04-04-2021</p>
              <h4>Lead PI(s)</h4>
              <p>John Smith, Robert Edwards, Joe Svensson</p>

              <div className="action-required-validation">
                <h4>Related Works(DOIs)</h4>
                <p>8 related works</p>
                <p>2 Unverified</p>
              </div>

              <h4>Repositories</h4>
              <p>Github</p>
              <h4>Is Public</h4>
              <p>Yes</p>
              <h4>Is Featured</h4>
              <p>No</p>
            </div>

            <div className="form-actions ">
              <button type="submit" className="primary">
                Update
              </button>
              <button type="button" onClick={() => setShow(false)}>
                Close
              </button>
            </div>
          </div>
        </div>
      </div>

      <div
        id="filter-modal"
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
                <h3>Filters</h3>
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
                  <TextInput
                    label="Funder"
                    type="text"
                    name="funder"
                    id="filter_funder"
                    placeholder=""
                    inputValue={filter_funder}
                    onChange={(e) => setFilter_Funder(e.target.value)}
                    help="Search for the name of the funder"
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
              <div className="form-actions">
                <button type="submit" className="primary">
                  Filter
                </button>
                <button
                  type="button"
                  onClick={() => setShowFilterDrawer(false)}
                >
                  Close
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Dashboard;
