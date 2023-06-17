import useContext from 'react';
import {useNavigate} from 'react-router-dom';
import {DmpApi} from '../../api';

import './new.scss';


function PlanNew() {
  let navigate = useNavigate();
  let dmpData = {};

  function handleSubmit(ev) {
    let api = new DmpApi();

    ev.preventDefault();
    console.log('Submit Form');

    // Collect the form data
    var stepData = {};
    const form = ev.target;
    const formData = new FormData(form);
    formData.forEach((value, key) => stepData[key] = value);

    // Make the save request
    let options = api.getOptions({
      method: "post",
      body: JSON.stringify({
        "dmp": {
          "title": stepData['project_name'],
          "dmphub_owner": {
            "mbox": api.me.mbox,
          },
        },
      }),
    });

    fetch(api.getPath('/wips'), options).then((resp) => {
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
    <div id="planNew">
      <h2>New Plan</h2>

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

export default PlanNew;
