import useContext from "react";
import { useNavigate } from "react-router-dom";

import { DmpApi } from "../../../api.js";
import TextInput from "../../../components/text-input/textInput.js";
import "./new.scss";


function PlanNew() {
  let navigate = useNavigate();

  async function handleSubmit(ev) {
    ev.preventDefault();
    let api = new DmpApi();

    const form = ev.target;
    const title = form.querySelector('[name="title"]');
    const narrative = form.querySelector('[name="narrative"]');

    let dmpData = {"title": title.value}
    if (narrative.files.length > 0) {
      const fileResult = await api.getFileDataURL(narrative.files[0]);
      dmpData["narrative"] = fileResult;
    }

    // const formData = new FormData(form);
    // formData.forEach((value, key) => (stepData[key] = value));
    // let headers = api.getHeaders();
    // headers.set('Content-Type', "application/x-www-form-urlencoded");

    let options = api.getOptions({
      method: "post",
      body: JSON.stringify({
        dmp: dmpData,
      }),
    });

    console.log('Fetch options');
    console.log(options);

    fetch(api.getPath("/drafts"), options)
      .then((resp) => {
        api.handleResponse(resp.status);
        return resp.json();
      })
      .then((data) => {
        let dmp = data.items[0].dmp;
        navigate(`/dashboard/dmp/${dmp.draft_id.identifier}`);
      });
  }

  return (
    <div id="planNew">
      <div className="dmpui-heading">
        <h1>New Plan</h1>
      </div>

      <form method="post" enctype="multipart/form-data" onSubmit={handleSubmit}>
        <div className="form-wrapper">
          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Project Name"
                type="text"
                required="required"
                name="title"
                id="title"
                placeholder="Project Name"
                help="All or part of the project name/title, e.g. 'Particle Physics'"
                error=""
              />
            </div>
          </div>

          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <div className={"dmpui-field-group"}>
                <label className="dmpui-field-label">Upload DMP</label>
                <p className="dmpui-field-help">
                  Only PDFs may be uploaded, and files should be no more than
                  250kb.
                </p>

                <div className="dmpui-field-fileinput-group  ">
                  <div className="">
                    <input
                      name="narrative"
                      type="file"
                    />
                  </div>
                </div>
              </div>
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

export default PlanNew;
