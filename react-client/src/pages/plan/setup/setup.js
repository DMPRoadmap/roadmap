import { useContext, useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";

import { DmpModel, getDraftDmp } from '../../../models.js';
import { DmpApi } from "../../../api.js";
import TextInput from "../../../components/text-input/textInput.js";
import "./setup.scss";


function DmpSetup() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState(new DmpModel({}));

  useEffect(() => {
    if (typeof dmpId !== "undefined") {
      getDraftDmp(dmpId).then((initial) => {
        setDmp(initial);
      });
    }
  }, [dmpId]);

  async function handleSubmit(ev) {
    ev.preventDefault();
    let api = new DmpApi();

    let formData = new FormData(ev.target);

    // NOTE: Remove the content-type header so that rails and browser will
    // figure it out If we don't do this, then the request always fail.
    var headers = api.getHeaders();
    headers.delete('Content-Type');

    // TODO:FIXME: We need to check with Brian what the PUT/POST path is for
    // updating, and htat page, same as this one, should accept the same
    // contenttype being sent (iow. NOT json!)
    let options = api.getOptions({
      headers: headers,
      method: "post",
      body: formData,
    });

    fetch(api.getPath("/drafts"), options)
      .then((resp) => {
        api.handleResponse(resp.status);
        return resp.json();
      })
      .then((data) => {
        let dmp = data.items[0].dmp;
        navigate(`/dashboard/dmp/${dmp.draft_id.identifier}/funders`);
      });
  }

  return (
    <div id="planNew">
      <div className="dmpui-heading">
        <h1>{dmpId ? "Update" : "New"} Plan</h1>
      </div>

      <form method="post" encType="multipart/form-data" onSubmit={handleSubmit}>
        <div className="form-wrapper">
          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Project Name"
                type="text"
                required="required"
                name="title"
                id="title"
                inputValue={dmp ? dmp.title : ""}
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
                      accept=".pdf"
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
          {dmpId ? (
              // TODO: This will render the button to "UPDATE" the dmp title
              // and PDF
              ""
            ) : (
              <button type="submit" className="primary">
                Save &amp; Continue
              </button>
            )}
        </div>
      </form>
    </div>
  );
}

export default DmpSetup;
