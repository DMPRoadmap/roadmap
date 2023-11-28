import { useContext, useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";

import {
  DmpModel,
  getDmp,
  saveDmp,
  registerDmp,
} from "../../../models.js";

import TextInput from "../../../components/text-input/textInput";
import RadioButton from "../../../components/radio/radio";
import Spinner from "../../../components/spinner";

import "./overview.scss";


function PlanOverview() {
  let navigate = useNavigate();
  const { dmpId } = useParams();
  const [dmp, setDmp] = useState(null);
  const [working, setWorking] = useState(false);

  useEffect(() => {
    getDmp(dmpId).then((initial) => {
      setDmp(initial);
    });
  }, [dmpId]);


  function handleChange(ev) {
    const { name, value } = ev.target;

    switch (name) {
      case "plan_visible":
        let newDmp = new DmpModel(dmp.getData());
        newDmp.privacy = value
        setDmp(newDmp);
        break;
    }
  }

  async function handleUpdateDmp(ev) {
    ev.preventDefault();
    setWorking(true);

    if (dmp.isValid()) {
      saveDmp(dmp).then((savedDmp) => {
        setDmp(savedDmp);
        setWorking(false);
      }).catch(err => {
        setWorking(false);
        console.log("Bad response from server");
        console.log(err.resp);
        console.log(err);
      });
    } else {
      setWorking(false);
      setDmp(newDmp);
      window.scroll(0, 0);
      console.log(dmp.errors);
    }
  }

  async function handleRegister(ev) {
    ev.preventDefault();
    setWorking(true);

    if (dmp.isValid()) {
      saveDmp(dmp).then((savedDmp) => {
        setDmp(savedDmp);
        registerDmp(savedDmp).then((data) => {
          const redirectUrl = ev.target.dataset['redirect'];
          navigate(redirectUrl);
        }).catch(err => {
          setWorking(false);
          console.log("Bad response from server");
          console.log(err.resp);
          console.log(err);
        });
      });
    } else {
      setWorking(false);
      let newDmp = new DmpModel(dmp.getData());
      newDmp.isValid();
      setDmp(newDmp);
      window.scroll(0, 0);
      console.log("Validation Errors");
      console.log(newDmp.errors);
    }
  }

  return (
    <>
      {!dmp ? (
        <Spinner isActive={true} message="Fetching DMP data…" className="page-loader" />
      ) : (
        <div id="addPlan">
          <div className="dmpui-heading">
            <h1>{dmp.title}</h1>
            {dmp.errors.size > 0 && (
              <div className="dmpui-field-error">
                Some steps require attention before we can register the DMP.
              </div>
            )}
          </div>

          <div className="plan-steps">
            <h2>Plan Setup</h2>

            <div className="plan-steps-step last">
              <p>
                <Link to={`/dashboard/dmp/${dmp.id}/pdf`}>
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
                <Link to={`/dashboard/dmp/${dmp.id}/funders`}>Funders</Link>
              </p>
              <div className={"step-status status-" + dmp.stepStatus.funders[0]}>
                {dmp.stepStatus.funders[1]}
              </div>
            </div>

            <div className="plan-steps-step">
              <p>
                <Link to={`/dashboard/dmp/${dmp.id}/project-details`}>
                  Project Details
                </Link>
              </p>

              <div className={"step-status status-" + dmp.stepStatus.project[0]}>
                {dmp.stepStatus.project[1]}
              </div>
              {dmp.errors.get("project") && (
                <div className={"step-status status-error"}>
                  Review Needed
                </div>
              )}
            </div>

            <div className="plan-steps-step">
              <p>
                <Link to={`/dashboard/dmp/${dmp.id}/contributors`}>
                  Contributors
                </Link>
              </p>

              <div className={"step-status status-" + dmp.stepStatus.contributors[0]}>
                {dmp.stepStatus.contributors[1]}
              </div>

              {dmp.errors.get("contributors") && (
                <div className={"step-status status-error"}>
                  Review Needed
                </div>
              )}
            </div>

            <div className="plan-steps-step ">
              <p>
                <Link to={`/dashboard/dmp/${dmp.id}/research-outputs`}>
                  Research Outputs
                </Link>
              </p>
              <div className={"step-status status-" + dmp.stepStatus.outputs[0]}>
                {dmp.stepStatus.outputs[1]}
              </div>
            </div>

            {dmp.isRegistered && (
              <div className="plan-steps-step last">
                <p>
                  <Link to={`/dashboard/dmp/${dmp.id}/related-works`}>
                    Related Works
                  </Link>
                </p>
                <div className={"step-status status-" + dmp.stepStatus.related[0]}>
                  {dmp.stepStatus.related[1]}
                </div>
              </div>
            )}

          </div>

          {!dmp.isRegistered && (
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
          )}

          <div className="page-actions">
            {dmp.errors.size > 0 && (
              <div className="dmpui-field-error">
                Some steps require attention before we can register the DMP.
              </div>
            )}

            {working && (
              <Spinner isActive={working} message="Registering …" className="empty-list" />
            )}

            {!working && (
              <button type="button" onClick={() => navigate("/dashboard")}>
                Return to Dashboard
              </button>
            )}

            {!working && !dmp?.isRegistered && (
              <>
                <button className="primary"
                  data-redirect="/dashboard"
                  onClick={handleRegister}>
                  Register & Return to Dashboard
                </button>
                <button className="secondary"
                  data-redirect="/dashboard/dmp/new"
                  onClick={handleRegister}>
                  Register & Add Another Plan
                </button>
              </>
            )}
          </div>
        </div>
      )}
    </>
  );
}

export default PlanOverview;
