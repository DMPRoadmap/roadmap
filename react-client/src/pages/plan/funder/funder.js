import { Link, useParams, useNavigate } from "react-router-dom";
import { useEffect, useState } from "react";
import { DmpApi } from "../../../api.js";

import TextInput from "../../../components/text-input/textInput";
import RadioButton from "../../../components/radio/radio";
import FunderLookup from "../../../components/funder-lookup/FunderLookup.js";
import { getValue } from "../../../utils.js";

import "./funder.scss";


function PlanFunders() {
  let navigate = useNavigate();
  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});

  const [funder, setFunder] = React.useState({name: ""});
  const [hasFunder, setHasFunder] = React.useState("no");
  const [funderNotListed, setFunderNotListed] = React.useState("false");

  useEffect(() => {
    let api = new DmpApi();
    fetch(api.getPath(`/drafts/${dmpId}`))
      .then((resp) => {
        api.handleResponse(resp);
        return resp.json();
      })
      .then((data) => {
        let initial = data.items[0].dmp;
        setDmp(initial);
        // TODO:: Funding is correctly saved and loaded, but the correct values
        // are not displayd in the fields below.
        // If a funder exists, we need to correctly set up the appropriate fields
        // below.
      });
  }, [dmpId]);


  function handleChange(ev) {
    const {name, value} = ev.target;

    switch (name) {
      case "have_funder":
        setHasFunder(value);
        if (hasFunder === "no") setFunderNotListed("false");
        break;

      case "funder_not_listed":
        setFunderNotListed(value);
        break;

      case "funder":
        setFunder(ev.data);
        break;

      case "unlisted_funder_name":
        setFunder({"name": value});
        break;
    }
  }


  async function handleSave(ev) {
    ev.preventDefault();
    let api = new DmpApi();

    let dmpProject = getValue(dmp, "project.0", {});
    let projectFunding = getValue(dmp, "project.0.funding.0", {});

    projectFunding = {
      ...projectFunding,

      // NOTE:: Important!!! You may be tempted to just put the "funder" object
      // in here as-is. But the funder returned by the API does not have the
      // same structure as expected in the DMP. This is why we manually
      // Set only the name and funder id fields here.
      ...{
        name: funder.name,
        funder_id: funder.funder_id,
      },
    };

    dmpProject = {
      ...dmpProject,
      ...{"funding": [projectFunding]}
    };

    let dmpData = {
      ...dmp,
      ...{project: [dmpProject]},
    };

    let options = api.getOptions({
      method: "put",
      body: JSON.stringify({ dmp: dmpData }),
    });

    fetch(api.getPath(`/drafts/${dmpId}`), options).then((resp) => {
      api.handleResponse(resp.status);
      return resp.json();
    }).then((data) => {
      // TODO:: Handle response errors
      navigate(`/dashboard/dmp/${dmpId}`);
    });
  }

  return (
    <>
      <div id="funderPage">
        <div className="dmpui-heading">
          <h1>Funder</h1>
        </div>

        <form method="post" enctype="multipart/form-data" onSubmit={handleSave}>
          <div className="form-wrapper">
            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                <div className={"dmpui-field-group"}>
                  <label className="dmpui-field-label">
                    Do you have a funder?
                  </label>
                  <p className="dmpui-field-help">
                    Is there a funder associated with this project?
                  </p>

                  <div onChange={handleChange}>
                    <RadioButton
                      label="No"
                      name="have_funder"
                      id="have_funder_no"
                      inputValue="no"
                      checked={hasFunder === "no"}
                    />

                    <RadioButton
                      label="Yes, I have a funder"
                      name="have_funder"
                      id="have_funder_yes"
                      inputValue="yes"
                      checked={hasFunder === "yes"}
                    />
                  </div>
                </div>
              </div>
            </div>

            {hasFunder && hasFunder === "yes" && (
              <div className="dmpui-form-cols">
                <div className="dmpui-form-col">
                  <FunderLookup
                    disabled={funderNotListed === "true"}
                    label="Find funder"
                    name="funder"
                    id="funder"
                    placeholder=""
                    help="Search for your funder by name."
                    inputValue={getValue(dmp, "project.0.funding.0.name", "")}
                    onChange={handleChange}
                    error=""
                  />

                  <div className="dmpui-field-checkbox-group not-listed">
                    <input
                      id="idUnlistedFunder"
                      className="dmpui-field-input-checkbox"
                      name="funder_not_listed"
                      value="true"
                      checked={funderNotListed === "true"}
                      onChange={handleChange}
                      type="checkbox"
                    />
                    <label
                      htmlFor="idUnlistedFunder"
                      className="checkbox-label"
                    >
                      My funder isn't listed
                    </label>
                  </div>
                </div>
              </div>
            )}

            {funderNotListed &&
              funderNotListed === "true" &&
              hasFunder &&
              hasFunder === "yes" && (
                <div className="dmpui-form-cols">
                  <div className="dmpui-form-col">
                    <TextInput
                      label="Enter Funders Name"
                      type="text"
                      required="required"
                      name="unlisted_funder_name"
                      id="unListedFunderName"
                      inputValue={getValue(dmp, "project.0.funding.0.name", "")}
                      onChange={handleChange}
                      placeholder=""
                      help="If your funder isn't listed, enter their name here."
                      error=""
                    />
                  </div>
                </div>
              )}
          </div>

          <div className="form-actions ">
            <button type="button" onClick={() => navigate(-1)}>
              Cancel
            </button>
            <button type="submit" className="primary">
              Save &amp; Continue
            </button>
          </div>
        </form>
      </div>
    </>
  );
}

export default PlanFunders;
