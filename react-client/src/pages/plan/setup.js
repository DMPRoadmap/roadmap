import {useNavigate} from 'react-router-dom';
import {
  api_path,
  api_headers,
  api_options,
} from '../../utils.js';

import './setup.scss';


function PlanSetup() {
  let navigate = useNavigate();
  let dmpData = {};

  function handleSubmit(ev) {
    ev.preventDefault();
    console.log('Submit Form');

    // Collect the form data
    var stepData = {};
    const form = ev.target;
    const formData = new FormData(form);
    formData.forEach((value, key) => stepData[key] = value);

    // Make the save request
    let url = api_path('/wips');
    let options = api_options({
      method: "post",
      headers: api_headers(),
      body: JSON.stringify({
        "dmp": {
          "title": stepData['project_name'],
          "dmphub_owner": {
            "mbox": "jane.doe@example.com"
          },
        },
      }),
    });
    fetch(url, options).then((resp) => {
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
      console.log('Handle Response');
      console.log(data.items.map(i => JSON.parse(i)));
      // navigate("/dmps/overview");
    });
  }

  // onClick={() => navigate("/dmps/funders")}

  return (
    <div id="planSetup">
      <h2>Plan Setup</h2>

      <form method="post" onSubmit={handleSubmit}>
        <div className="form-field required">
          <div className="form-field-label">
            <label>Project Name</label>
            <p className="help-text">
              All or part of the project name/title, e.g. 'Particle Physics'
            </p>
          </div>
          <div className="form-field-input">
            <input name="project_name" type="text" />
          </div>
        </div>

        <div className="form-field required">
          <div className="form-field-label">
            <label>Upload DMP</label>
            <p className="help-text">
              Only PDFs may be uploaded, and files should be no more than
              250kb.
            </p>
          </div>

          <div className="form-field-input todo">
            <input name="project_pdf" type="file" />
          </div>
        </div>

        <div className="form-actions todo">
          <button type="button" onClick={() => navigate("/dashboard")}>Cancel</button>
          <button type="submit" className="primary">
            Save &amp; Continue
          </button>
        </div>

      </form>

    </div>
  )
}

export default PlanSetup
