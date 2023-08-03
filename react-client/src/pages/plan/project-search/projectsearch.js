import {
  useEffect,
  useState,
  useRef,
  Fragment
} from "react";
import { useParams, useNavigate } from "react-router-dom";

import { DmpApi } from "../../../api";
import {getValue, useDebounce, isEmpty} from "../../../utils.js";
import TextInput from "../../../components/text-input/textInput";
import TextArea from "../../../components/textarea/textArea";
import "./projectsearch.scss";


function ProjectSearch() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState({});
  const [contributors, setContributors] = useState([]);
  const [queryArgs, setQueryArgs] = useState(null);
  const debounceQuery = useDebounce(queryArgs, 500);

  var controller;

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


  // TODO::FIXME:: Even though we Abort the request, a request was still sent,
  // and the rails backend probably sent it off as well.
  // We need to add a separate debounce as well.
  useEffect(() => {
    if (!isEmpty(debounceQuery)) {
      let api = new DmpApi();

      if (controller) controller.abort();
      controller = new AbortController();

      let headers = api.getHeaders();
      headers.set("Content-Type", "text/plain")
      let options = api.getOptions({
        headers: headers,
        signal: controller.signal,
      });

      let funderUrl = getValue(dmp, "draft_data.funder.funder_api", null);
      let url = new URL(funderUrl);
      let searchParams = new URLSearchParams(queryArgs);
      url.search = searchParams.toString();

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
          console.log("Error?");
          console.log(err);
          if (err.name === "AbortError") { console.log('Aborted'); }
          setContributors([]);
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

  function handleSubmit(ev) {
    ev.preventDefault();

    console.log('Submit?');
    console.log(ev);

    // TODO::
    // navigate(`/dashboard/dmp/${dmpId}/project-details?locked=true`);
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
