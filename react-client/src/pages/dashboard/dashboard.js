import { useEffect, useState, Fragment } from "react";
import { useNavigate, Link } from "react-router-dom";

import { DmpApi } from "../../api.js";
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
        </div>
        <div className="filter-button">
          <button className="button">Filter</button>
        </div>
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
                        {item.dmp?.title}
                      </td>
                      <td className="table-data-name" data-colname="funder">
                        {item?.dmp?.project?.[0]?.funding?.[0]?.name ?? "n/a"}
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
                      <td className="table-data-name" data-colname="actions">
                        <Link
                          to={`/dashboard/dmp/${item.dmp.draft_id.identifier}`}
                        >
                          Edit
                        </Link>
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
