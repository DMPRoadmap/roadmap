import { useContext, useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";

import {
  DmpModel,
  getDraftDmp,
  saveDraftDmp,
  registerDraftDmp,
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


  function handleChange(ev) {
    const {name, value} = ev.target;

    switch(name) {
      case "plan_visible":
        let newDmp = new DmpModel(dmp.getData());
        newDmp.privacy = value
        break;
    }
  }


  async function handleRegister(ev) {
    ev.preventDefault();

    saveDraftDmp(dmp).then((savedDmp) => {
      setDmp(savedDmp);
      registerDraftDmp(savedDmp).then((data) => {
        const redirectUrl = ev.target.dataset['redirect'];
        navigate(redirectUrl);
      }).catch(err => {
        console.log("Bad response from server");
        console.log(err.resp);
        console.log(err);
      });
    });

    // TODO
    // We don't want people to "double-click" and register the same thing twice.
    // So we can disble the save button here, while working, and re-enable when
    // we are done.
  }


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
                <div className="dmpui-field-group" onChange={handleChange}>
                  <label className="dmpui-field-label">
                    Set visibility and register your plan
                  </label>

                  <RadioButton
                    name="plan_visible"
                    id="plan_visible_no"
                    inputValue="private"
                    checked={dmp.privacy === "private"}
                    label="Private - Keep plan private and only visible to me"
                  />

                  <RadioButton
                    name="plan_visible"
                    id="plan_visible_yes"
                    inputValue="public"
                    checked={dmp.privacy === "public"}
                    label="Public - Keep plan visible to the public"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>

        <div className="page-actions">
          <button type="button" onClick={() => navigate("/dashboard")}>
            Return to Dashboard
          </button>
          <button className="primary"
                  data-redirect="/dashboard"
                  onClick={handleRegister}>
            Register &amp; Return to Dashboard
          </button>
          <button className="secondary"
                  data-redirect="/dashboard/dmp/new"
                  onClick={handleRegister}>
            Register &amp; Add Another Plan
          </button>
        </div>
      </div>
    </>
  );
}

export default PlanOverview;
