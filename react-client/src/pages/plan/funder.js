import {useNavigate} from 'react-router-dom';

import './funder.scss';


function PlanFunders() {
  let navigate = useNavigate();

  return (
    <>
      <div id="funderPage">
        <h2>Project: Funder</h2>

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

        <div className="form-field required">
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

        <div className="form-actions todo">
          <button onClick={() => navigate("/dashboard")}>Cancel</button>
          <button className="primary">Save &amp; Continue</button>
        </div>
      </div>
    </>
  )
}

export default PlanFunders;
