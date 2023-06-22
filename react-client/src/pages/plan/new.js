import useContext from 'react';
import {useNavigate} from 'react-router-dom';
import {DmpApi} from '../../api';

import './new.scss';


function PlanNew() {
  let navigate = useNavigate();
  let dmpData = {};

  async function handleSubmit(ev) {
    ev.preventDefault();
    let api = new DmpApi();

    // Collect the form data
    var stepData = {};
    const form = ev.target;
    const formData = new FormData(form);

    formData.forEach((value, key) => stepData[key] = value);

    const fileResult = await api.getFileDataURL(stepData['project_pdf'])

    // NOTE: We must remove the content type headers for the PDF boundary to
    // work correctly
    let headers = api.getHeaders();
    headers.delete('Content-Type');

    let options = api.getOptions({
      method: "post",
      headers: headers,
      body: JSON.stringify({
        "dmp": {
          "title": stepData['project_name'],
          "narrative": fileResult,
        }
      }),
    });

    fetch(api.getPath('/dmps'), options).then((resp) => {
      api.handleResponse(resp.status);
      return resp.json();
    }).then((data) => {
      let dmp = data.items[0].dmp;
      navigate(`/dashboard/dmp/${dmp.wip_id.identifier}`);
    });
  }

  return (
    <div id="planNew">
      <h2>New Plan</h2>

      <form method="post" enctype="multipart/form-data" onSubmit={handleSubmit}>
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
