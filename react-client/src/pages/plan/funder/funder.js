import { Link, useParams, useNavigate } from "react-router-dom";
import { useEffect, useState } from "react";

import TextInput from "../../../components/text-input/textInput";
import RadioButton from "../../../components/radio/radio";
import LookupField from "../../../components/lookup-field.js";
import Spinner from "../../../components/spinner";

import {
  getDmp,
  saveDmp,
  Funding,
} from "../../../models.js";

import "./funder.scss";


function PlanFunders() {
  let navigate = useNavigate();
  const { dmpId } = useParams();

  const [dmp, setDmp] = useState();
  const [isLocked, setLocked] = useState(false);
  const [funder, setFunder] = React.useState({ name: "" });
  const [hasFunder, setHasFunder] = React.useState("no");

  useEffect(() => {
    getDmp(dmpId).then((initial) => {
      setDmp(initial);
      if (initial.hasFunder) {
        let draftFunder = initial.getDraftData("funder", initial.funding.getData())
        setFunder(draftFunder);
        setHasFunder("yes");
        setLocked(true);
      }
    });
  }, [dmpId]);

  function handleChange(ev) {
    const { name, value } = ev.target;

    switch (name) {
      case "have_funder":
        setHasFunder(value);
        break;

      case "funder":
        if (ev.data) {
          setFunder(ev.data);
        } else {
          setFunder({ ...funder, name: value });
        }
        break;
    }
  }

  function handleUnlock(ev) {
    ev.preventDefault();
    setLocked(!isLocked);
  }


  async function handleSave(ev) {
    ev.preventDefault();

    if (isLocked) {
      if (dmp.hasFunder && dmp.funderApi) {
        navigate(`/dashboard/dmp/${dmp.id}/project-search`);
      } else {
        navigate(`/dashboard/dmp/${dmp.id}/project-details`);
      }
      return;
    }

    // Update and then Commit the changes to the DMP model
    if (hasFunder === "yes") {
      dmp.setDraftData("funder", funder);
      dmp.funding.name = funder.name;
      if (funder.funder_id) dmp.funding.funderId = funder.funder_id;
    } else {
      dmp.project.funding = new Funding({ name: "None" });
      dmp.setDraftData("funder", {});
      dmp.commit();
    }

    saveDmp(dmp).then((savedDmp) => {
      if (savedDmp.hasFunder && dmp.funderApi) {
        navigate(`/dashboard/dmp/${savedDmp.id}/project-search`);
      } else {
        navigate(`/dashboard/dmp/${savedDmp.id}/project-details`);
      }
    });
  }


  return (
    <>
      {!dmp ? (
        <Spinner isActive={true} message="Loading DMP funder page…" className="page-loader" />
      ) : (
        <div id="funderPage">
          <div className="dmpui-heading">
            <h1>Funder</h1>
          </div>

          {isLocked && (
            <div className="dmpui-search-form-container alert alert-warning">
              <p>
                This information is not editable because the funder have already
                been selected.
              </p>
              {!dmp.isRegistered && (
                <p>
                  <br />
                  <button
                    onClick={handleUnlock}
                    className="button">
                    Unlock & Edit
                  </button>
                </p>
              )}
            </div>
          )}

          <form method="post" encType="multipart/form-data" onSubmit={handleSave}>
            <div className="form-wrapper">
              <div className="dmpui-form-cols">
                <div className="dmpui-form-col">

                  <fieldset className={"dmpui-field-group"}>
                    <legend className="dmpui-field-label">
                      Do you have a funder?
                    </legend>
                    <p className="dmpui-field-help">
                      Is there a funder associated with this project?
                    </p>

                    <div onChange={handleChange}>
                      <RadioButton
                        label="No"
                        name="have_funder"
                        id="have_funder_no"
                        inputValue="no"
                        disabled={isLocked}
                        checked={hasFunder === "no"}
                      />

                      <RadioButton
                        label="Yes, I have a funder"
                        name="have_funder"
                        id="have_funder_yes"
                        inputValue="yes"
                        disabled={isLocked}
                        checked={hasFunder === "yes"}
                      />
                    </div>

                  </fieldset>

                </div>
              </div>

              {hasFunder && hasFunder === "yes" && (
                <div className="dmpui-form-cols">
                  <div className="dmpui-form-col">
                    <LookupField
                      label="Funder Name"
                      name="funder"
                      id="funder"
                      endpoint="funders"
                      placeholder="Search ..."
                      help="Search for your funder by name. If you can't find your funder in the list, just type it in."
                      inputValue={funder.name ? funder.name : ""}
                      onChange={handleChange}
                      disabled={isLocked}
                      error=""
                    />
                  </div>
                </div>
              )}
            </div>



          <div className="form-actions ">
            <button type="button" onClick={() => navigate(`/dashboard/dmp/${dmp.id}`)}>
              {dmp.isRegistered ? "Back" : "Cancel"}
            </button>
            {!dmp.isRegistered && (
              <button type="submit" className="primary">
                Save & Continue
              </button>
              )}
            </div>
          </form>
        </div>
      )}
    </>
  );
}

export default PlanFunders;
