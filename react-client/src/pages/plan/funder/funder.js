import {
  Link,
  useParams,
  useNavigate,
} from 'react-router-dom';

import {
  useEffect,
  useState,
} from 'react';

import { DmpApi } from '../../../api.js';
import './funder.scss';


function PlanFunders() {
  let navigate = useNavigate();
  const { dmpId } = useParams();
  const [dmp, setDmp] = useState({});

  useEffect(() => {
    let api = new DmpApi();
    fetch(api.getPath(`/dmps/${dmpId}`)).then((resp) => {
      api.handleResponse(resp);
      return resp.json();
    }).then((data) => {
      setDmp(data.items[0].dmp);
    });
  }, [dmpId]);

  async function handleSave(ev) {
    ev.preventDefault();
    let api = new DmpApi();

    // Collect the form data
    var stepData = {};
    const form = ev.target;
    const formData = new FormData(form);

    formData.forEach((value, key) => stepData[key] = value);

    console.log('DMPS?');
    console.log(dmp);

    console.log('Step Data');
    console.log(stepData);

    // TODO:: Add the funder to the DMP data
    // This is the expected structure to add to the DMP
    //
    // NOTE:: This data will come from the Funder typeahead input field.
    //
    // {
    //   "project": [{
    //     "funding": [
    //       {
    //         "dmproadmap_project_number": "prj-XYZ987-UCB",
    //         "grant_id": {
    //           "type": "other",
    //           "identifier": "776242"
    //         },
    //         "name": "National Science Foundation",
    //         "funder_id": {
    //           "type": "fundref",
    //           "identifier": "501100002428"
    //         },
    //         "funding_status": "granted",
    //         "dmproadmap_opportunity_number": "Award-123"
    //       }
    //     ]
    //   }]
    // }

    let options = api.getOptions({
      method: "put",
      body: JSON.stringify({ "dmp": dmp }),
    });

    // fetch(api.getPath('/dmps'), options).then((resp) => {
    //   api.handleResponse(resp.status);
    //   return resp.json();
    // }).then((data) => {
    //   let dmp = data.items[0].dmp;
    //   navigate(`/dashboard/dmp/${dmpId}`);
    // });
  }

  return (
    <>
      <div id="funderPage">

        <div className="dmpui-heading">
          <h1>Project: Funder</h1>
        </div>




        <form method="post" enctype="multipart/form-data" onSubmit={handleSave}>

          <div className="form-wrapper">

            <div className="form-field required">
              <div className="form-field-label">
                <label>Do you have a funder?</label>
                <p className="help-text">
                  Is there a funder associated with this project?
                </p>
              </div>
              <div className="form-field-input">
                <span>Funder</span>
                <label>
                  <input name="has_funder" type="radio" />
                  yes
                </label>
                <label>
                  <input name="has_funder" type="radio" />
                  no
                </label>
              </div>
            </div>

            <div className="form-field last required">
              <div className="form-field-label">
                <label>Funder</label>
                <p className="help-text">
                  Begin typing to select your funder from a list.
                </p>
              </div>
              <div className="form-field-input">
                <label>Funder Name</label>
                <input name="tmp" type="text" defaultValue="" />
                <label>
                  <input id="id_funder_not_listed" name="funder_not_listed" type="checkbox" />
                  My funder isn't listed
                </label>
              </div>
            </div>

          </div>

          <div className="form-actions ">
            <button type="button" onClick={() => navigate(-1)}>Cancel</button>
            <button type="submit" className="primary">Save &amp; Continue</button>
          </div>
        </form>



      </div>
    </>
  )
}

export default PlanFunders;
