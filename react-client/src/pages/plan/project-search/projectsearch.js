import {
  useEffect,
  useState,
  Fragment
} from "react";
import { useParams, useNavigate } from "react-router-dom";

import { DmpApi } from "../../../api.js";
import { getDraftDmp, saveDraftDmp } from "../../../models.js";
import { getValue, useDebounce, isEmpty} from "../../../utils.js";
import TextInput from "../../../components/text-input/textInput";
import "./projectsearch.scss";


function ProjectSearch() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});
  const [selected, setSelected] = useState(null);
  const [projects, setProjects] = useState([]);
  const [queryArgs, setQueryArgs] = useState(null);
  const debounceQuery = useDebounce(queryArgs, 500);

  var controller;


  useEffect(() => {
    getDraftDmp(dmpId).then((initial) => {
      setDmp(initial);

      console.log('Draft DMP Loaded');
      console.log(initial);

      let funderUrl = initial.getDraftData("funder.funder_api", null);

      console.log("funderUrl? " + funderUrl);
      console.log("Has Funder?");
      console.log(initial.hasFunder);

      if (!initial.hasFunder || !funderUrl) {
        navigate(`/dashboard/dmp/${dmpId}/project-details`);
      }

      setQueryArgs({
        ...queryArgs,
        title: initial.title,
      });
    });
  }, [dmpId]);


  useEffect(() => {
    if (!isEmpty(debounceQuery)) {
      if (controller) controller.abort();
      controller = new AbortController();

      console.log("Degug Query");
      console.log("Dmp?");
      console.log(dmp);

      let funderUrl = dmp.getDraftData("funder.funder_api", null);
      console.log(funderUrl);

      if (!funderUrl) {
        console.log(`Error! Invalid funder api url, ${funderUrl}.`);
        console.log(dmp.getData());
      } else {
        console.log("Going to make the request?");

        let url = new URL(funderUrl);

        console.log("api url? " + url);

        let searchParams = new URLSearchParams(queryArgs);
        url.search = searchParams.toString();

        console.log("Search params?");
        console.log(searchParams);

        let api = new DmpApi();
        let headers = api.getHeaders();
        headers.set("Content-Type", "text/plain")
        let options = api.getOptions({
          headers: headers,
          signal: controller.signal,
        });

        console.log("Searching the funder api now");
        fetch(url, options)
          .then((resp) => {
            api.handleResponse(resp);
            return resp.json();
          })
          .then((data) => {
            setProjects(data.items);
          })
          .catch((err) => {
            if (err.name === "AbortError") { console.log('Aborted'); }
            setProjects([]);
          });
      }
    } else {
      setQueryArgs({});
    }

    // Cleanup the controller on component unmount
    return () => {
      if (controller) controller.abort();
    };
  }, [debounceQuery]);


  function handleChange(ev) {
    const {name, value} = ev.target;

    switch (name) {
      case "project_id":
        setQueryArgs({
          ...queryArgs,
          project: value,
        })
        break;

      case "project_name":
        setQueryArgs({
          ...queryArgs,
          title: value,
        });
        break;

      case "principle_investigator":
        setQueryArgs({
          ...queryArgs,
          pi_names: value,
        });
        break;

      case "award_year":
        setQueryArgs({
          ...queryArgs,
          years: value,
        });
        break;
    }
  }


  function handleSelect(ev) {
    setSelected(parseInt(ev.target.dataset.index, 10));
  }


  async function handleSave(ev) {
    ev.preventDefault();

    if (selected !== null) {
      const item = projects[selected];

      dmp.project.title = getValue(item, "project.title", "");
      dmp.project.description = getValue(item, "project.description", "");

      dmp.project.setStart(getValue(item, "project.start", ""));
      dmp.project.setEnd(getValue(item, "project.end", ""));

      dmp.funding.grantId = getValue(item, "project.funding.0.grant_id", {});
      dmp.funding.projectNumber = getValue(
        item, "project.funding.0.dmproadmap_project_number");

      dmp.contact.name = getValue(item, "contact");
      dmp.contributors = getValue(item, "contributor");

      saveDraftDmp(dmp).then((savedDmp) => {
        navigate(`/dashboard/dmp/${dmpId}/project-details`);
      });
    }
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

        <form method="post">
          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Project Number or ID"
                type="text"
                required="required"
                name="project_id"
                onChange={handleChange}
                inputValue=""
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
                inputValue={dmp ? dmp.title : ""}
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
                inputValue=""
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
                inputValue=""
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
        {projects.length === 0 ? (
          <>
            <div className="empty-list">
              <p>Start searching to find your project…</p>
            </div>
          </>
        ) : (
          <>
            <div className="row-wrapper">
              <div className="data-heading" data-colname="name">Project Name</div>
              <div className="data-heading" data-colname="role">ID</div>
              <div className="data-heading" data-colname="actions"></div>
            </div>

            {projects.map((item, index) => (
              <Fragment key={index}>
                <div className="row-wrapper"
                  className={(index == selected) ? "row-wrapper selected" : "row-wrapper"}>
                  <div data-colname="name">
                    {getValue(item, "project.title", "")}
                  </div>
                  <div data-colname="id">
                    {getValue(item, "project.funding.0.dmproadmap_project_number", "")}
                  </div>
                  <div data-colname="actions">
                    <button
                      onClick={handleSelect}
                      data-index={index}>
                      Select
                    </button>
                  </div>
                </div>
              </Fragment>
            ))}
          </>
        )}
      </div>

      <form method="post" onSubmit={handleSave}>
        <div className="form-wrapper"></div>

        <div className="form-actions ">
          <button type="button" onClick={() => navigate(-1)}>
            Cancel
          </button>

          <button
            type="submit"
            className="primary"
            disabled={selected === null}>
            Save &amp; Continue
          </button>
        </div>
      </form>
    </div>
  );
}

export default ProjectSearch;
