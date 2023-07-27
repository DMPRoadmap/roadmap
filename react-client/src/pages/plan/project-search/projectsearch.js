import {
  useContext,
  useEffect,
  useState,
  Fragment
} from "react";
import { useParams, useNavigate } from "react-router-dom";

import { DmpApi } from "../../../api";
import { getValue } from "../../../utils.js";
import TextInput from "../../../components/text-input/textInput";
import TextArea from "../../../components/textarea/textArea";
import "./projectsearch.scss";


function ProjectSearch() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});
  const [contributors, setContributors] = useState([
    {
      id: "3523535",
      name: "Dinosaur Decibels: How Roaring Dinosaurs Impact Children's Education",
      role: "8881-2424-2424-1133",
    },
    {
      id: "3245678",
      name: "Bibliophiles Unleashed: The Impact of Reading Aloud in Early Childhood Education",
      role: "8881-2424-2424-1134",
    },
    {
      id: "3879123",
      name: "Mathematical Mountains: Scaling the Heights of Mathematics Achievement in Primary Schools",
      role: "8881-2424-2424-1135",
    },
    {
      id: "4098234",
      name: "Educational Ecosystems: The Role of School Gardens in Holistic Learning",
      role: "8881-2424-2424-1136",
    },
    {
      id: "5123987",
      name: "Tech Titans: The Transformative Power of Digital Tools in Modern Classrooms",
      role: "8881-2424-2424-1137",
    },
    {
      id: "6123459",
      name: "Mindful Classrooms: Exploring the Integration of Mindfulness Practices in K-12 Education",
      role: "8881-2424-2424-1138",
    },
  ]);

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

        console.log(initial);

        let f = getValue(initial, "project.0.funding.0", null);
        if (f) {
          if (f.name) {
            // TODO::
            //
            // Okay we have a funder. Get the list of projects for this funder
            // that con-incide with our name.
          }
        }
      });
  }, [dmpId]);

  function handleChange(ev) {
    const {name, value} = ev.target;
    console.log(`Handle Change; ${name}: ${value}`);

    // NOTE:: We only start auto searching soon as there are at least 3
    // characters in a input field. There is no need to search with less.

    switch (name) {
      case "project_id":
        break;

      case "project_name":
        break;

      case "principle_investigator":
        break;

      case "award_year":
        break;
    }
  }

  async function handleSearch(ev) {
    ev.preventDefault();

    //navigate(`/dashboard/dmp/${dmpId}/project-details?locked=true`);
  }

  async function handleSubmit(ev) {
    ev.preventDefault();

    // TODO::

    navigate(`/dashboard/dmp/${dmpId}/project-details?locked=true`);
  }

  return (
    <div id="ProjectSearch">
      <div className="dmpui-heading">
        <h1>Plan Details</h1>
      </div>

      <div className="dmpui-search-form-container">
        <h2>Find your project</h2>
        <p>
          Tell us more about your project. Enter as much info below as you can.
          We'll use this to locate key information.
        </p>

        <form method="post" enctype="multipart/form-data">
          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Project Number or ID"
                type="text"
                required="required"
                name="project_id"
                onChange={handleChange}
                id="project_id"
                placeholder="Project ID"
                help="The Project ID or number provided by your funder"
                error=""
              />
            </div>

            <div className="dmpui-form-col">
              <TextInput
                label="Project Name"
                type="text"
                required="required"
                name="project_name"
                onChange={handleChange}
                id="project_name"
                placeholder="Project Name"
                help="All or part of the project name/title, e.g. 'Particle Physics'"
                error=""
              />
            </div>
          </div>

          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Principle Investigator (PI)"
                type="text"
                required="required"
                name="principle_investigator"
                onChange={handleChange}
                id="principle_investigator"
                placeholder=""
                help="PI Names or Profile IDs, semicolon ';' separated"
                error=""
              />
            </div>

            <div className="dmpui-form-col">
              <TextInput
                label="Award Year"
                type="text"
                required="required"
                name="award_year"
                onChange={handleChange}
                id="award_year"
                placeholder="Award Year"
                help="e.g. 2020"
                error=""
              />
            </div>
          </div>
        </form>
      </div>

      <div className="dmpdui-list ">
        <div className="data-heading" data-colname="name">
          Project Name
        </div>
        <div className="data-heading" data-colname="role">
          ID
        </div>
        <div className="data-heading" data-colname="actions"></div>
        {contributors.map((item) => (
          <Fragment key={item.id}>
            <div data-colname="name">{item.name}</div>
            <div data-colname="role">{item.role}</div>
            <div data-colname="actions">
              <button onClick={handleSubmit}>Select</button>
            </div>
          </Fragment>
        ))}
      </div>

      <form method="post" enctype="multipart/form-data" onSubmit={handleSubmit}>
        <div className="form-wrapper"></div>

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

export default ProjectSearch;
