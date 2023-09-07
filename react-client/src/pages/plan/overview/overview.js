import { useContext, useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";

import {
  DmpModel,
  getDraftDmp,
} from "../../../models.js";

import TextInput from "../../../components/text-input/textInput";
import RadioButton from "../../../components/radio/radio";
import "./overview.scss";


function PlanOverview() {
  let navigate = useNavigate();
  const { dmpId } = useParams();
  const [dmp, setDmp] = useState(new DmpModel({}));


  useEffect(() => {
    getDraftDmp(dmpId).then((initial) => {
      setDmp(initial);
    });
  }, [dmpId]);


  return (
    <>
      <div id="addPlan">
        <div className="dmpui-heading">
          <h1>{dmp.title}</h1>
        </div>

        <div className="plan-steps">
          <h2>Plan Setup</h2>

          <div className="plan-steps-step last">
            <p>
              <Link to={`/dashboard/dmp/${dmpId}/pdf`}>
                Project name & PDF upload
              </Link>
            </p>
            <div className={"step-status status-" + dmp.stepStatus.setup[0]}>
              {dmp.stepStatus.setup[1]}
            </div>
          </div>
        </div>

        <div className="plan-steps">
          <h2>Project</h2>

          <div className="plan-steps-step">
            <p>
              <Link to={`/dashboard/dmp/${dmpId}/funders`}>Funders</Link>
            </p>
            <div className={"step-status status-" + dmp.stepStatus.funders[0]}>
              {dmp.stepStatus.funders[1]}
            </div>
          </div>

          <div className="plan-steps-step">
            <p>
              <Link to={`/dashboard/dmp/${dmpId}/project-details`}>
                Project Details
              </Link>
            </p>

            <div className={"step-status status-" + dmp.stepStatus.project[0]}>
              {dmp.stepStatus.project[1]}
            </div>
          </div>

          <div className="plan-steps-step">
            <p>
              <Link to={`/dashboard/dmp/${dmpId}/contributors`}>
                Contributors
              </Link>
            </p>

            <div className={"step-status status-" + dmp.stepStatus.contributors[0]}>
              {dmp.stepStatus.contributors[1]}
            </div>
          </div>

          <div className="plan-steps-step last">
            <p>
              <Link to={`/dashboard/dmp/${dmpId}/research-outputs`}>
                Research Outputs
              </Link>
            </p>
            <div className={"step-status status-" + dmp.stepStatus.outputs[0]}>
              {dmp.stepStatus.outputs[1]}
            </div>
          </div>
        </div>

        <div className="plan-steps">
          <h2>Register</h2>

          <div className="plan-steps-step last step-visibility">
            <div className="">
              <div className="dmpui-form-col">
                <div className={"dmpui-field-group"}>
                  <label className="dmpui-field-label">
                    Set visibility and register your plan
                  </label>

                  <div className="dmpui-field-radio-group">
                    <input
                      type="radio"
                      className="dmpui-field-input-radio"
                      name="plan_visible"
                      id="plan_visible_false"
                      value="private"
                    />
                    <label htmlFor="plan_visible_false" className="radio-label">
                      Private - Keep plan private and only visible to me
                    </label>
                  </div>

                  <div className="dmpui-field-radio-group">
                    <input
                      type="radio"
                      className="dmpui-field-input-radio"
                      name="plan_visible"
                      id="plan_visible"
                      checked="checked"
                      value="public"
                    />
                    <label htmlFor="plan_visible" className="radio-label">
                      Public - Keep plan visible to the public
                    </label>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="page-actions">
          <button type="button" onClick={() => navigate("/dashboard")}>
            Return to Dashboard
          </button>
          <button className="primary" onClick={() => navigate("/dashboard")}>
            Register &amp; Return to Dashboard
          </button>
          <button className="secondary" onClick={() => navigate("/dashboard")}>
            Register &amp; Add Another Plan
          </button>
        </div>
      </div>
    </>
  );
}

export default PlanOverview;
