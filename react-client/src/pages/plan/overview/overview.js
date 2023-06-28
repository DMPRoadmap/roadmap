import {
  Link,
  useNavigate,
  useParams,
} from 'react-router-dom';

import {
  useContext,
  useEffect,
  useState,
} from 'react';

import { DmpApi } from '../../../api.js';



import TextInput from '../../../components/text-input/textInput';


function PlanOverview() {
  let navigate = useNavigate();
  const { dmpId } = useParams();
  const [dmp, setDmp] = useState({});


  let page_title = "Upload a Plan";


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



  if (dmp.title) {
    page_title = `${dmp.title}`;
  }



  return (
    <>
      <div id="addPlan">
        <div className="dmpui-heading">

          <h1>
            {`${page_title}`}
          </h1>
        </div>



        <div className="plan-steps">
          <h2>Plan Setup</h2>

          <div className="plan-steps-step last">

            <p>
              <Link to={`/dashboard/dmp/${dmpId}/project-details`}>
                Project name & PDF upload
              </Link>
            </p>
            <div className="step-status status-completed">Completed</div>
          </div>
        </div>

        <div className="plan-steps">
          <h2>Project</h2>

          <div className="plan-steps-step">
            <p>
              <Link to={`/dashboard/dmp/${dmpId}/funders`}>
                Funders
              </Link>
            </p>
            <div className="step-status status-completed">Completed</div>
          </div>

          <div className="plan-steps-step">

            <p>
              <Link to={`/dashboard/dmp/${dmpId}/project-details`}>
                Project Details
              </Link>
            </p>

            <div className="step-status status-completed">Completed</div>
          </div>

          <div className="plan-steps-step">


            <p>
              <Link to={`/dashboard/dmp/${dmpId}/contributors`}>
                Contributors
              </Link>
            </p>

            <div className="step-status status-notstart">Not Started</div>
          </div>

          <div className="plan-steps-step last">

            <p>
              <Link to={`/dashboard/dmp/${dmpId}/research-outputs`}>
                Research Outputs
              </Link>
            </p>
            <div className="step-status status-recommended">Recommended</div>
          </div>
        </div>

        <div className="plan-steps">
          <h2>Register</h2>

          <div className="plan-steps-step last step-visibility">
            <p>Set visibility and register your plan</p>
            <div className="input">
              <input name="plan_private" type="checkbox" /> Keep plan private <br />
              <input name="plan_visible" type="checkbox" /> Keep plan visible
            </div>
          </div>
        </div>

        <div className="page-actions">


          <button type="button" onClick={() => navigate("/dashboard")}>Return to Dashboard</button>
          <button className="primary" onClick={() => navigate("/dashboard")} >Register &amp; Return to Dashboard</button>
          <button className="secondary" onClick={() => navigate("/dashboard")}>Register &amp; Add Another Plan</button>
        </div>
      </div>
    </>
  )
}

export default PlanOverview
