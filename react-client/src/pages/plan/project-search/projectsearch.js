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

  var controller = new AbortController();
  var queryArgs = {};

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});
  const [contributors, setContributors] = useState([]);
  // {
  //   id: "3523535",
  //   name: "Dinosaur Decibels: How Roaring Dinosaurs Impact Children's Education",
  //   role: "8881-2424-2424-1133",
  // },
  // {
  //   id: "3245678",
  //   name: "Bibliophiles Unleashed: The Impact of Reading Aloud in Early Childhood Education",
  //   role: "8881-2424-2424-1134",
  // },
  // {
  //   id: "3879123",
  //   name: "Mathematical Mountains: Scaling the Heights of Mathematics Achievement in Primary Schools",
  //   role: "8881-2424-2424-1135",
  // },
  // {
  //   id: "4098234",
  //   name: "Educational Ecosystems: The Role of School Gardens in Holistic Learning",
  //   role: "8881-2424-2424-1136",
  // },
  // {
  //   id: "5123987",
  //   name: "Tech Titans: The Transformative Power of Digital Tools in Modern Classrooms",
  //   role: "8881-2424-2424-1137",
  // },
  // {
  //   id: "6123459",
  //   name: "Mindful Classrooms: Exploring the Integration of Mindfulness Practices in K-12 Education",
  //   role: "8881-2424-2424-1138",
  // },

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
      });
  }, [dmpId]);

  function handleSearch(funderUrl) {
    let api = new DmpApi();

    if (controller) {
      controller.abort();
      console.log("... aborted ...");
    }
    controller = new AbortController();
    let signal = controller.signal;

    let headers = api.getHeaders();
    headers.set("Content-Type", "text/plain")
    let options = api.getOptions({
      headers: headers,
      signal: signal,
    });
    let url = new URL(funderUrl, api.baseUrl);
    let searchParams = new URLSearchParams(queryArgs);
    url.search = searchParams.toString();

    console.log('Fetch options?');
    console.log(options);

    fetch(url, options)
      .then((resp) => {
        api.handleResponse(resp);
        return resp.json();
      })
      .then((data) => {
        console.log('Response?');
        console.log(data);
        setContributors(data.items);
      })
      .catch((err) => {
        if (err.name === "AbortError") { console.log('Aborted'); }
        if (err.response && err.response.status === 404) {
          setContributors([]);
        }
      });
  }

  function handleChange(ev) {
    ev.preventDefault();

    const {name, value} = ev.target;
    console.log(`Handle Change; ${name}: ${value}`);

    switch (name) {
      case "project_id":
        queryArgs["project"] = value
        break;

      case "project_name":
        queryArgs["title"] = value
        break;

      case "principle_investigator":
        queryArgs["pi_names"] = value
        break;

      case "award_year":
        queryArgs["years"] = value
        break;
    }

    let funderUrl = getValue(dmp, "draft_data.funder.funder_api", null);
    if (funderUrl) handleSearch(funderUrl);
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

      <div className="dmpdui-list project-list">
        {contributors.length === 0 ? (
          <>
            <div className="empty-list">
              <p>Start searching to find your project…</p>
            </div>
          </>
        ) : (
          <>
            <div className="data-heading" data-colname="name">Project Name</div>
            <div className="data-heading" data-colname="role">ID</div>
            <div className="data-heading" data-colname="actions"></div>

            {contributors.map((item) => (
              <Fragment key={item.id}>
                <div data-colname="name">{getValue(item, "project.title", "")}</div>
                <div data-colname="id">
                  {getValue(item, "project.funding.0.dmproadmap_project_number", "")}
                </div>
                <div data-colname="actions">
                  <button onClick={handleSubmit}>Select</button>
                </div>
              </Fragment>
            ))}
          </>
        )}
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
