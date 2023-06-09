import React from 'react';
import {useEffect, useState, Fragment} from 'react';
import {useNavigate} from 'react-router-dom';
import {
  api_path,
  api_headers,
  api_options
} from '../utils.js';

import './dashboard.scss';

function Dashboard() {
  const [projects, setProjects] = useState([]);
  let navigate = useNavigate();

  useEffect(() => {

console.log('called useEffect');

    let url = api_path('/wips', {
      owner: "jane.doe@example.com",
    });
    let options = api_options({
      headers: api_headers(),
    });

console.log(url);
console.log(options);

    fetch(url, options).then((resp) => {

console.log(`API respnse: #{resp.status}`);

      switch (resp.status) {
        case 200:
          return resp.json();
          break;

        default:
          // TODO:: Error handling
          // TODO:: Log and report errors to a logging services
          // TODO:: Message to display to the user?
          console.log('Error fetching from API');
          console.log(resp);
      }
    }).then((data) => {
      console.log(data.items.map(i => JSON.parse(i)));
      setProjects(data.items.map(i => JSON.parse(i)));
    });
  }, []);

  function dmp_id_for(dmp) {

console.log('called dmp_id_for');

    return dmp.dmphub_wip_id.identifier;
  }

  return (
    <div id="Dashboard">
      <h2>
        Dashboard
        <button className="primary" onClick={() => navigate("/plan/add")}>
          Add Plan
        </button>
      </h2>

      <div className="project-list todo">
        <div className="data-heading" data-colname="title">Project Name</div>
        <div className="data-heading" data-colname="funder">Funder</div>
        <div className="data-heading" data-colname="grantId">Grant ID</div>
        <div className="data-heading" data-colname="dmpId">DMP ID</div>
        <div className="data-heading" data-colname="status">Status</div>
        <div className="data-heading" data-colname="actions"></div>

        <div data-colname="title">Static test Project</div>
        <div data-colname="funder">NIH</div>
        <div data-colname="grantId">12345-A</div>
        <div data-colname="dmpId"></div>
        <div data-colname="status">
          Incomplete <br />
          <progress max="10" value="7"/>
        </div>
        <div data-colname="actions">
          <a href="#">Complete</a>
        </div>

        {projects.map(item => (
          <Fragment key={item.dmp.dmphub_wip_id.identifier}>
            <div data-colname="title">{item.dmp?.title}</div>
            <div data-colname="funder">{item?.funder}</div>
            <div data-colname="grantId">tbd…</div>
            <div data-colname="dmpId">
              {item.dmp.dmphub_wip_id.identifier}
            </div>
            <div data-colname="status">
              Incomplete <br />
              <progress max="10" value="3"/>
            </div>
            <div data-colname="actions">
              <a href="#">tbd…</a>
            </div>
          </Fragment>
        ))}
      </div>
    </div>
  )
}


export default Dashboard
