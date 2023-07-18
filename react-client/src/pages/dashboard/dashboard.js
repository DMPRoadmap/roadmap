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

      <div className="plan-steps">
        <div className="project-list todo">
          <div className="data-heading" data-colname="title">
            Project Name
          </div>
          <div className="data-heading" data-colname="funder">
            Funder
          </div>
          <div className="data-heading" data-colname="grantId">
            Grant ID
          </div>
          <div className="data-heading" data-colname="dmpId">
            DMP ID
          </div>
          <div className="data-heading" data-colname="status">
            Status
          </div>
          <div className="data-heading" data-colname="actions"></div>

          {projects.map((item) => (
            <Fragment key={item.dmp.draft_id.identifier}>
              <div data-colname="title">{item.dmp?.title}</div>
              <div data-colname="funder">{item?.funder}</div>
              <div data-colname="grantId">tbd…</div>
              <div data-colname="dmpId">{item.dmp.draft_id.identifier}</div>
              <div data-colname="status">
                Incomplete <br />
                <progress max="10" value="3" />
              </div>
              <div data-colname="actions">
                <Link to={`/dashboard/dmp/${item.dmp.draft_id.identifier}`}>
                  Complete
                </Link>
              </div>
            </Fragment>
          ))}
        </div>
      </div>
    </div>
  );
}

export default Dashboard;
