import { useContext, useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";

import { DmpModel, getDraftDmp } from '../../../models.js';
import { DmpApi } from "../../../api.js";

import TextInput from "../../../components/text-input/textInput.js";
import Checkbox from "../../../components/checkbox/checkbox.js";

import "./setup.scss";


function DmpSetup() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [dmp, setDmp] = useState(new DmpModel({}));
  const [errors, setErrors] = useState(new Map());

  useEffect(() => {
    if (typeof dmpId !== "undefined") {
      getDraftDmp(dmpId).then((initial) => {
        setDmp(initial);
      });
    }
  }, [dmpId]);


  function isValid(fdata) {
    let err = new Map();

    const sizeLimit = 1000000;
    if (fdata.get("narrative").size > sizeLimit) {
      err.set("narrative", "File size cannot exceed 1 Mb");
    }

    if (!fdata.get("title")) {
      err.set("title", "Title cannot be blank");
    }

    setErrors(err);
    if (err.size > 0) return false;
    return true;
  }


  async function handleSubmit(ev) {
    ev.preventDefault();

    let api = new DmpApi();
    let formData = new FormData(ev.target);

    if (isValid(formData)) {
      // NOTE: Remove the content-type header so that rails and browser will
      // figure it out If we don't do this, then the request always fail.
      var headers = api.getHeaders();
      headers.delete('Content-Type');
      let options = api.getOptions({
        headers: headers,
        method: "post",
        body: formData,
      });

      if (!dmpId) {
        options.method = "post";

        fetch(api.getPath("/drafts"), options)
          .then((resp) => {
            api.handleResponse(resp);
            return resp.json();
          })
          .then((data) => {
            let dmp = data.items[0].dmp;
            navigate(`/dashboard/dmp/${dmp.draft_id.identifier}/funders`);
          });
      } else {
        // NOTE: We cannot use the saveDraftDmp helper function here since
        // the headers and content type is different during this setup step
        // (due to the PDF narrative)
        options.method = "put";

        fetch(api.getPath(`/drafts/${dmpId}/narrative`), options)
          .then((resp) => {
            api.handleResponse(resp);
            return resp.json();
          })
          .then((data) => {
            navigate(`/dashboard/dmp/${dmpId}`);
          });
      }
    } else {
      console.log(errors);
    }
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
                error={errors.get("title")}
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
                {errors.get("narrative") && (
                  <p className="dmpui-field-error"> {errors.get("narrative")} </p>
                )}

                <div className="dmpui-field-fileinput-group">
                  <div>
                    <Checkbox
                      label="Remove PDF"
                      name="remove_narrative"
                      id="primaryContact"
                      inputValue="yes"
                    />

                    <br />

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
          <button type="button" onClick={() => {
            if (dmpId) {
              navigate(`/dashboard/dmp/${dmpId}`);
            } else {
              navigate('/dashboard');
            }
          }}>
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

export default DmpSetup;
