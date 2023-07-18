import { useEffect, useState } from "react";
import {
  Link,
  useParams,
  useNavigate,
  useSearchParams,
} from "react-router-dom";

import { DmpApi } from "../../../api.js";
import { getValue } from "../../../utils.js";
import TextInput from "../../../components/text-input/textInput.js";
import TextArea from "../../../components/textarea/textArea.js";

import "./projectdetails.scss";


function ProjectDetails() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});
  const [formData, setFormData] = useState({
    project_name: "",
    project_id: "",
    project_abstract: "",
    start_date: "",
    end_date: "",
    award_number: "",
  })

  const [searchParams, setSearchParams] = useSearchParams();

  useEffect(() => {
    let api = new DmpApi();

    fetch(api.getPath(`/drafts/${dmpId}`))
      .then((resp) => {
        api.handleResponse(resp);
        return resp.json();
      })
      .then((data) => {
        let dmp = data.items[0].dmp
        setDmp(dmp);
        setFormData({
          project_name: getValue(dmp, "title", ""),
          project_id: dmpId,
          project_abstract: getValue(dmp, "description", ""),
          start_date: getValue(dmp, "project.0.start", ""),
          end_date: getValue(dmp, "project.0.end", ""),
          award_number: getValue(dmp, "project.0.funding.0.dmproadmap_opportunity_number", ""),
        });
      });
  }, [dmpId]);

  // FIXME::TODO:: Is this the correct way to do this?
  // Is there another way to get this information rather than a URL parameter?
  // Reason: Url Parameters state can be too easilly manipulated
  let is_locked = searchParams.get("locked");

  function handleChange(ev) {
    const {name, value} = ev.target;
    setFormData({
      ...formData,
      [name]: value,
    });
  }

  async function handleSubmit(ev) {
    ev.preventDefault();
    let api = new DmpApi();

    // TODO:: QUESTION:
    // The funding and project keys are arrays, does this mean there is a
    // potential for multiple objects to be returned in future? And if so,
    // should we be concerned with which one of the multiple objects to
    // display and/or update.

    // Update the DMP from the submitted formData
    // Use spread operator to update the dmp data, but we separate nested
    // structures so that we can be explicit about the updates.
    let dmpProject = getValue(dmp, "project.0", {});
    let projectFunding = getValue(dmp, "project.0.funding.0", {});

    projectFunding = {
      ...projectFunding,
      ...{"dmproadmap_opportunity_number": formData.award_number || ""},
    };

    dmpProject = {
      ...dmpProject,
      ...{
        "title": formData.project_name,
        "description": formData.project_abstract || "",
        "start": formData.start_date || "",
        "end": formData.end_date || "",
      },
      ...{"funding": [projectFunding]},
    }

    // Finally put it all together
    let dmpData = {
      ...dmp,
      ...{"title": formData.project_name || ""},
      ...{"project": [dmpProject]},
    }

    let options = api.getOptions({
      method: "put",
      body: JSON.stringify({dmp: dmpData}),
      // body: JSON.stringify(dmpData),
    });

    fetch(api.getPath(`/drafts/${dmpId}`), options).then((resp) => {
      api.handleResponse(resp.status);
      return resp.json();
    }).then((data) => {
      // FIXME:: Handle response errors
      navigate(`/dashboard/dmp/${dmpId}/`);
    });
  }

  return (
    <div id="ProjectDetails">
      <div className="dmpui-heading">
        <h1>Plan Details</h1>
      </div>
      {is_locked && (
        <div className="dmpui-search-form-container alert alert-warning">
          <p>
            This information is not directly editable because it has been
            provided by your funder. If you wish to change the Project Details,
            go back and select a different project. Or you can select “My
            project isn't listed” to enter these details manually.
          </p>
          <p>
            <br />
            <button className="button">Unlock & Edit</button>
          </p>
        </div>
      )}
      <form method="post" enctype="multipart/form-data" onSubmit={handleSubmit}>
        <div className="form-wrapper">
          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Project Name"
                type="text"
                inputValue={formData.project_name}
                onChange={handleChange}
                required="required"
                name="project_name"
                id="project_name"
                placeholder="Project Name"
                help="All or part of the project name/title, e.g. 'Particle Physics'"
                error=""
              />
            </div>

            <div className="dmpui-form-col">
              <TextInput
                label="Project Number or ID"
                type="text"
                inputValue={formData.project_id}
                onChange={handleChange}
                required="required"
                name="project_id"
                id="project_id"
                placeholder="Project ID"
                help="The Project ID or number provided by your funder"
                error=""
              />
            </div>
          </div>

          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextArea
                label="Project Abstract"
                type="text"
                inputValue={formData.project_abstract}
                onChange={handleChange}
                required="required"
                name="project_abstract"
                id="project_abstract"
                placeholder=""
                help="A short summary of your project."
                error=""
              />
            </div>
          </div>

          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Project Start Date"
                type="date"
                inputValue={formData.start_date}
                onChange={handleChange}
                required="required"
                name="start_date"
                id="start_date"
                placeholder=""
                help=""
                error=""
              />
            </div>
            <div className="dmpui-form-col">
              <TextInput
                label="Project End Date"
                type="date"
                inputValue={formData.end_date}
                onChange={handleChange}
                required="required"
                name="end_date"
                id="end_date"
                placeholder=""
                help=""
                error=""
              />
            </div>
          </div>

          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Opportunity / Federal award number"
                type="text"
                inputValue={formData.award_number}
                onChange={handleChange}
                required="required"
                name="award_number"
                id="ppportunity_number"
                placeholder="Opportunity number"
                help="The Federal ID number if you have one, or the opportunity number."
                error=""
              />
            </div>
          </div>
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
  );
}

export default ProjectDetails;
