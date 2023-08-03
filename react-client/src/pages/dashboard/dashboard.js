import { useEffect, useState, Fragment } from "react";
import { useNavigate, Link } from "react-router-dom";

import { DmpApi } from "../../api.js";
import { truncateText } from "../../utils.js";
import { DmpModel } from "../../models.js";
import "./dashboard.scss";
function Dashboard() {
  const [projects, setProjects] = useState([]);
  const [user, setUser] = useState({
    givenname: "",
    surname: "",
  });

  let navigate = useNavigate();

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
    fetch(api.getPath("/drafts"), api.getOptions())
      .then((resp) => {
        api.handleResponse(resp);
        return resp.json();
      })
      .then((data) => {
        console.log(data.items);
        setProjects(data.items);

        // ready to convert to dmp model
        //   const dmpModels = data.items.map((item) => new DmpModel(item.dmp));
        //       setProjects(dmpModels);
      });
  }, []);

  function dmp_id_for(dmp) {
    return dmp.draft_id.identifier;
  }

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

      <div className="filter-container">
        <div className="filter-status">
          <h5>Status</h5>
          <div className="filter-quicklinks">
            <a href="/?status=all">All</a>
            <a href="/?status=registered">Registered</a>
            <a href="/?status=incomplete">Incomplete</a>
          </div>
        </div>
        <div className="filter-edited">
          <h5>Edited</h5>
          <div className="filter-quicklinks">
            <a href="/?status=all">All</a>
            <a href="/?status=lastweek">Last week</a>
            <a href="/?status=lastmonth">Last Month</a>
          </div>
        </div>
        <div className="filter-tags">
          <h5>Filters</h5>
          <button className="button">Filter</button>
        </div>
        <div className="filter-button"></div>
      </div>

      <div className="plan-steps">
        <div class="table-container">
          <div class="table-wrapper">
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
                {projects.map((item) => (
                  <Fragment key={item.dmp.draft_id.identifier}>
                    <tr key={item.dmp.draft_id.identifier}>
                      <td className="table-data-name" data-colname="title">
                        <span title={item.dmp?.title}>
                          {truncateText(item.dmp?.title, 50)}
                        </span>
                        <a href="#" class="preview-button">
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            height="18"
                            viewBox="0 -960 960 960"
                            width="18"
                          >
                            <path d="M433-344v-272L297-480l136 136ZM180-120q-24.75 0-42.375-17.625T120-180v-600q0-24.75 17.625-42.375T180-840h600q24.75 0 42.375 17.625T840-780v600q0 24.75-17.625 42.375T780-120H180Zm453-60h147v-600H633v600Zm-60 0v-600H180v600h393Zm60 0h147-147Z" />
                          </svg>
                        </a>

                        <div className="d-block table-data-pi">
                          PI: {truncateText("John Smith", 50)}
                          {item.dmp.draft_id.identifier &&
                            item.dmp.draft_id.identifier ===
                              "20230629-570ca751fdb0"(
                                <span>X works need verification</span>
                              )}
                        </div>
                      </td>
                      <td className="table-data-name" data-colname="funder">
                        <span
                          title={item?.dmp?.project?.[0]?.funding?.[0]?.name}
                        >
                          {truncateText(
                            item?.dmp?.project?.[0]?.funding?.[0]?.name,
                            10
                          )}
                        </span>
                      </td>
                      <td
                        className="table-data-date"
                        data-colname="last_edited"
                      >
                        03-29-2023
                      </td>
                      <td className="table-data-name" data-colname="status">
                        {item?.dmp?.project?.[0]?.status ?? "Incomplete"}
                      </td>
                      <td
                        className="table-data-name table-data-actions"
                        data-colname="actions"
                      >
                        {item.dmp.draft_id.identifier &&
                        item.dmp.draft_id.identifier ===
                          "20230629-570ca751fdb0" ? (
                          <Link
                            className="edit-button"
                            to={`/dashboard/dmp/${item.dmp.draft_id.identifier}`}
                          >
                            Complete
                          </Link>
                        ) : (
                          <Link
                            className="edit-button"
                            to={`/dashboard/dmp/${item.dmp.draft_id.identifier}`}
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
    </div>
  );
}

export default Dashboard;
