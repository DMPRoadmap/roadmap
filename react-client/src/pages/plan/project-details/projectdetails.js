import { useEffect, useState } from "react";
import {
  Link,
  useParams,
  useNavigate,
  useSearchParams,
} from "react-router-dom";

import { DmpApi } from "../../../api";

import TextInput from "../../../components/text-input/textInput";
import TextArea from "../../../components/textarea/textArea";
import "./projectdetails.scss";


function getValue(obj, path) {
  if (typeof path === 'string') path = path.split(".");

  if (path.length === 0) throw "Path Length is Zero";
  if (path.length === 1) return obj[path[0]];

  if (obj[path[0]]) {
    return getValue(obj[path[0]], path.slice(1));
  } else {
    console.log(obj[path[0]])
    obj[path[0]] = {};
    return getValue(obj[path[0]], path.slice(1));
  }
};

function ProjectDetails() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});
  const [searchParams, setSearchParams] = useSearchParams();

  useEffect(() => {
    let api = new DmpApi();

    fetch(api.getPath(`/dmps/${dmpId}`))
      .then((resp) => {
        api.handleResponse(resp);
        return resp.json();
      })
      .then((data) => {
        setDmp(data.items[0].dmp);
      });
  }, [dmpId]);

  let is_locked = searchParams.get("locked");

  // let testData = {
  //   project_name: dmp.title ? dmp.title : "",
  //   project_id: "",
  //   project_abstract: "",
  //   start_date: "",
  //   end_date: "",
  //   award_number: "",
  // };

  // if (is_locked) {
  //   testData = {
  //     project_name:
  //       "Dinosaur Decibels: How Roaring Dinosaurs Impact Children's Education",
  //     project_id: "8881-2424-2424-1133",
  //     project_abstract:
  //       "We explore the effects of prolonged exposure to dinosaur roars on children's eeducation. The  dilemmas faced by parents and caregivers in the age of dino-induced auditory adventures.",
  //     start_date: "2021-01-01",
  //     end_date: "2021-12-31",
  //     award_number: "GA-0024-ACB-1",
  //   };
  // }

  async function handleSubmit(ev) {
    ev.preventDefault();
    let api = new DmpApi();

    navigate(`/dashboard/dmp/${dmpId}/`);

    let options = api.getOptions({
      method: "post",
      body: JSON.stringify({
        "dmp": {
          "title": stepData['project_name'],
          "narrative": fileResult,
        }
      }),
    });

    fetch(api.getPath('/dmps'), options).then((resp) => {
      api.handleResponse(resp.status);
      return resp.json();
    }).then((data) => {
      let dmp = data.items[0].dmp;
      navigate(`/dashboard/dmp/${dmp.wip_id.identifier}`);
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
                inputValue={getValue(dmp, "title")}
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
                inputValue={getValue(dmp, "wip_id.identifier")}
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
                inputValue={getValue(dmp, "project.description")}
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
                inputValue={getValue(dmp, "project.start")}
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
                inputValue={getValue(dmp, "project.end")}
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
                inputValue={getValue(dmp, "")}
                required="required"
                name="ppportunity_number"
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
