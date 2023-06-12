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
  const [user, setUser] = useState([]);
  let navigate = useNavigate();

  console.log('fooooooooo!');

  useEffect(() => {
    // Hardcoding this because utils.js is throwing an error and I don't know why
    //   Unexpected Application Error!
    //     arguments[key].clone is not a function. (In 'arguments[key].clone()', 'arguments[key].clone' is undefined)

    let meUrl = 'http://localhost:3000/api/v2/me'
    let meOptions = {};

    // Call the local DMPTool Rails app's API to get the currently logged in user's info
    fetch(meUrl, meOptions).then((resp) => {
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
      console.log(data.items[0]);
      setUser(data.items[0]);
    });

    // Hardcoding this because utils.js is throwing an error and I don't know why
    //   Unexpected Application Error!
    //     arguments[key].clone is not a function. (In 'arguments[key].clone()', 'arguments[key].clone' is undefined)
    //let url = api_path('/wips', {
    //  owner: user.email,
    //});
    //let options = api_options({
    //  headers: api_headers(),
    //});
    let url = 'http://localhost:3000/dmps/'
    let headers = new Headers();
    headers.append('Accept', "application/json");
    headers.append('Authorization', `Bearer ${user.token}`);
    let options = Object.assign({
      method: 'get',
      mode: 'cors',
      cache: 'no-cache',
    }, headers);

    // Fetch the work in progress DMPs for the currently logged in user
    fetch(url, options).then((resp) => {
      console.log(resp);

      switch (resp.status) {
        case 200:
          return resp.json();
          break;

        case 204:
          return { items: [] }
          break;

        default:
          // TODO:: Error handling
          // TODO:: Log and report errors to a logging services
          // TODO:: Message to display to the user?
          console.log('Error fetching from API');
          console.log(resp);
      }
    }).then((data) => {
      console.log(data.items);
      setProjects(data.items);
    });
  }, []);

  function dmp_id_for(dmp) {
    return dmp.dmphub_wip_id.identifier;
  }

  return (
    <div id="Dashboard">
      <p>Welcome back {user.givenname } {user.surname}</p>
      <p><a href="/plans" className="exit-prototype">Back to standard Dashboard</a></p>

      <h2>
        Dashboard
        <button className="primary" onClick={() => navigate("/dmps/new")}>
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
