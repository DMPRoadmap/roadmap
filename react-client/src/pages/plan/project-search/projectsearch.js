import {
  useEffect,
  useState,
  Fragment
} from "react";
import { useParams, useNavigate } from "react-router-dom";

import { DmpApi } from "../../../api.js";
import {
  getDmp,
  saveDmp,
  Contributor,
} from "../../../models.js";
import { getValue, useDebounce, isEmpty } from "../../../utils.js";

import TextInput from "../../../components/text-input/textInput";
import Spinner from "../../../components/spinner";

import "./projectsearch.scss";


function ProjectSearch() {
  let navigate = useNavigate();

  const { dmpId } = useParams();
  const [dmp, setDmp] = useState();
  const [selected, setSelected] = useState(null);
  const [projects, setProjects] = useState([]);
  const [queryArgs, setQueryArgs] = useState(null);
  const [searching, setSearching] = useState(false);
  const debounceQuery = useDebounce(queryArgs, 500);

  var controller;


  useEffect(() => {
    getDmp(dmpId).then((initial) => {
      if (!initial.hasFunder || !initial.funderApi) {
        navigate(`/dashboard/dmp/${initial.id}/project-details`);
      } else {
        setDmp(initial);
        setQueryArgs({
          ...queryArgs,
          title: initial.title,
        });
      }
    });
  }, [dmpId]);


  useEffect(() => {
    if (!isEmpty(debounceQuery)) {
      if (controller) controller.abort();
      controller = new AbortController();

      let api = new DmpApi();
      let headers = api.getHeaders();
      headers.set("Content-Type", "text/plain")
      let options = api.getOptions({
        headers: headers,
        signal: controller.signal,
      });

      setSearching(true);

      let url = api.getFullPath(dmp.funderApi, queryArgs);
      fetch(url, options)
        .then((resp) => {
          api.handleResponse(resp);
          setSearching(false);
          return resp.json();
        })
        .then((data) => {
          setProjects(data.items);
        })
        .catch((err) => {
          if (err.name === "AbortError") { console.log('Aborted'); }
          setProjects([]);
        });
    } else {
      setQueryArgs({});
    }

    // Cleanup the controller on component unmount
    return () => {
      if (controller) controller.abort();
    };
  }, [debounceQuery]);


  function handleChange(ev) {
    const { name, value } = ev.target;

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

    // set aria-pressed to true and change the text to "selected" on the button that was clicked
    const buttons = document.querySelectorAll("button[data-index]");
    buttons.forEach((button) => {
      button.setAttribute("aria-pressed", false);
      button.innerHTML = "Select";
    });
    ev.target.setAttribute("aria-pressed", true);
    ev.target.innerHTML = "Selected";

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

      dmp.contributors = getValue(item, "contributor");
      dmp.contributors.items.forEach((c, i) => {
        if (c.roles.length === 0) {
          c.addRole("other");
          dmp.contributors.update(i, c);
        }
      });

      if (item.contact) {
        let c = new Contributor(getValue(item, "contact"));
        c.contact = true;
        if (c.roles.length === 0)
          c.addRole("other");
        dmp.contributors.add(c);
      }

      saveDmp(dmp).then((savedDmp) => {
        navigate(`/dashboard/dmp/${dmpId}/project-details`);
      });
    }
  }


  return (
    <>
      {!dmp ? (
        <Spinner isActive={true} message="Loading search data …" className="page-loader" />
      ) : (
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

          <h2 id="project-list-header" className="project-list-header">Search Results</h2>

          <div className="table-container">
            <div className="table-wrapper">
              <table className="dmpdui-list-table dmpui-table  project-search-table" aria-live="polite" aria-labelledby="project-list-header">
                {projects.length === 0 ? (
                  <tbody className="table-body">
                    <tr className="empty-list">
                      {!searching ? (
                        <td colSpan="3">
                          <p className="" aria-live='polite' role="status">Start searching to find your project…</p>
                        </td>
                      ) : (
                        <td colSpan="3">
                          <Spinner isActive={searching} message="Searching…" />
                        </td>
                      )}
                    </tr>
                  </tbody>
                ) : (
                  <>
                    {!searching && (
                      <thead>
                        <tr className="row-wrapper">
                          <th className="table-header-name data-heading" data-colname="name">Project Name</th>
                          <th className="table-header-name data-heading" data-colname="role">ID</th>
                          <th className="table-header-name data-heading" data-colname="actions"></th>
                        </tr>
                      </thead>
                    )}

                    {searching && <Spinner isActive={searching} message="Searching…" className="empty-list" />}

                    <tbody className="table-body">
                      {projects.map((item, index) => (
                        <tr key={index} className={index === selected ? "row-wrapper selected" : "row-wrapper"}>
                          <td data-colname="name" className="table-data-name " id={"project-" + index}>
                            {getValue(item, "project.title", "")}
                          </td>
                          <td data-colname="id" className="table-data-name " >
                            {getValue(item, "project.funding.0.dmproadmap_project_number", "")}
                          </td>
                          <td data-colname="actions" className="table-data-name table-data-actions" >
                            <button
                              id={"select-project-" + index}
                              aria-labelledby={"select-project-" + index + " " + "project-" + index}
                              onClick={handleSelect}
                              aria-pressed={false}
                              data-index={index}>
                              Select
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </>
                )}
              </table>
            </div>
          </div>

          <form method="post" onSubmit={handleSave}>



            <div className="form-actions ">

            <button type="button" onClick={() => navigate(`/dashboard/dmp/${dmpId}`)}>
              Cancel
            </button>

            <button
              type="submit"
              className="primary"
              disabled={selected === null}>
              Save & Continue
            </button>
            </div>
          </form>
        </div>
      )}
    </>
  );
}

export default ProjectSearch;
