import {
  Link,
  useParams,
} from 'react-router-dom';

import {
  useEffect,
  useState,
} from 'react';

import {DmpApi} from '../../api.js';

// import './overview.scss';


function PlanOverview() {
  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});

  useEffect(() => {
    let api = new DmpApi();

    fetch(api.getPath(`/dmps/${dmpId}`)).then((resp) => {
      api.handleResponse(resp);
      return resp.json();
    }).then((data) => {
      console.log(data.items[0]);
      setDmp(data.items[0].dmp);
    });
  }, [dmpId]);

  return (
    <>
      <div id="addPlan">
        <h2>Add a Plan</h2>
        <div className="plan-steps">
          <h3>Plan Setup</h3>

          <div className="plan-steps-step">
            <p>{`${dmp.title}`}</p>
            <div className="step-status status-completed">Completed</div>
          </div>
        </div>

        <div className="plan-steps">
          <h3>Project</h3>

          <div className="plan-steps-step">
            <Link to={`/dashboard/dmp/${dmpId}/funders`}>
              Funders
            </Link>
            <div className="step-status status-completed"></div>
          </div>

          <div className="plan-steps-step">
            <p>Project Details</p>
            <div className="step-status status-completed">Completed</div>
          </div>

          <div className="plan-steps-step">
            <p>Contributors</p>
            <div className="step-status status-completed">Completed</div>
          </div>

          <div className="plan-steps-step">
            <p>Research Outputs</p>
            <div className="step-status status-completed">Recommended</div>
          </div>
        </div>

        <div className="plan-steps">
          <h3>Register</h3>

          <div className="plan-steps-step step-visibility">
            <p>Set visibility and register your plan</p>
            <div className="input">
              <input name="plan_private" type="checkbox" /> Keep plan private <br />
              <input name="plan_visible" type="checkbox" /> Keep plan visible
            </div>
          </div>
        </div>

        <div className="page-actions">
          <button>Register &amp; Return to Dashboard</button>
          <button>Register &amp; Add Another Plan</button>
        </div>
      </div>
    </>
  )
}

export default PlanOverview
