import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";

import { getDraftDmp, saveDraftDmp } from "../../../models.js";
import { getValue } from "../../../utils.js";
import TextInput from "../../../components/text-input/textInput.js";
import TextArea from "../../../components/textarea/textArea.js";

import "./projectdetails.scss";


function ProjectDetails() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});
  const [formData, setFormData] = useState({});
  const [isLocked, setLocked] = useState(true);

  useEffect(() => {
    getDraftDmp(dmpId).then(initial => {
      setDmp(initial);
      setFormData({
        project_name: initial.title,
        project_id: initial.funding.projectNumber,
        project_abstract: initial.project.description,
        start_date: initial.project.start.format("YYYY-MM-DD"),
        end_date: initial.project.end.format("YYYY-MM-DD"),
        award_number: initial.funding.opportunityNumber,
      });
    });

  }, [dmpId]);

  function handleUnlock(ev) {
    ev.preventDefault();
    setLocked(!isLocked);
  }

  function handleChange(ev) {
    const {name, value} = ev.target;
    setFormData({
      ...formData,
      [name]: value,
    });
  }

  async function handleSubmit(ev) {
    ev.preventDefault();

    if (isLocked) {
      navigate(`/dashboard/dmp/${dmpId}/`);
      return;
    }

    dmp.title = formData.project_name;
    dmp.project.title = formData.project_name;
    dmp.project.description = formData.project_abstract;

    dmp.project.setStart(formData.start_date);
    dmp.project.setEnd(formData.end_date);
    dmp.funding.projectNumber = formData.project_id || "";
    dmp.funding.opportunityNumber = formData.award_number || "";

    saveDraftDmp(dmp).then((savedDmp) => {
      navigate(`/dashboard/dmp/${dmpId}/`);
    });
  }

  return (
    <div id="ProjectDetails">
      <div className="dmpui-heading">
        <h1>Plan Details</h1>
      </div>

      {isLocked && (
        <div className="dmpui-search-form-container alert alert-warning">
          <p>
            This information is not directly editable because it has been
            provided by your funder. If you wish to change the Project Details,
            go back and select a different project. Or you can select “My
            project isn't listed” to enter these details manually.
          </p>
          <p>
            <br />
            <button
              onClick={handleUnlock}
              className="button">
              Unlock & Edit
            </button>
          </p>
        </div>
      )}

      <form method="post" encType="multipart/form-data" onSubmit={handleSubmit}>
        <div className="form-wrapper">
          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Project Name"
                type="text"
                inputValue={formData.project_name}
                onChange={handleChange}
                disabled={isLocked}
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
                disabled={isLocked}
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
                disabled={isLocked}
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
                inputType="date"
                inputValue={formData.start_date}
                onChange={handleChange}
                disabled={isLocked}
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
                inputType="date"
                inputValue={formData.end_date}
                onChange={handleChange}
                disabled={isLocked}
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
                disabled={isLocked}
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
          <button type="button" onClick={() => navigate(`/dashboard/dmp/${dmpId}`)}>
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
