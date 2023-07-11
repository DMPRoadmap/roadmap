import { Link, useNavigate, useParams } from "react-router-dom";

import { useContext, useEffect, useState, Fragment } from "react";

import { DmpApi } from "../../../api.js";

// forms
import TextInput from "../../../components/text-input/textInput.js";
import TextArea from "../../../components/textarea/textArea.js";

function ResearchOutputs() {
  let navigate = useNavigate();

  let data = [
    {
      id: "1",
      title: "Figure 1",
      personal: "No",
      sensitive: "No",
      repo: "No",
      type: "Image",
    },
    {
      id: "2",
      title: "Dataset",
      personal: "No",
      sensitive: "No",
      repo: "No",
      type: "Dataset",
    },
    {
      id: "3",
      title: "Dateset2",
      personal: "No",
      sensitive: "No",
      repo: "No",
      type: "Dataset",
    },
    {
      id: "4",
      title: "Demographics",
      personal: "yes",
      sensitive: "No",
      repo: "No",
      type: "Dataset",
    },
  ];

  return (
    <div id="ResearchOutputs">
      <div className="dmpui-heading">
        <h1>Research Outputs</h1>
      </div>

      <p>Add or edit research outputs to your data management plan.</p>

      <div className="dmpdui-top-actions">
        <div>
          <button
            className="secondary"
            onClick={() => navigate("/dashboard/dmp/new")}
          >
            Add Output
          </button>
        </div>
      </div>

      <div className="dmpdui-list dmpdui-list-research ">
        <div className="data-heading" data-colname="title">
          Title
        </div>
        <div className="data-heading" data-colname="personal">
          Personal information?
        </div>
        <div className="data-heading" data-colname="sensitive">
          Sensitive data?
        </div>
        <div className="data-heading" data-colname="repo">
          Repository
        </div>
        <div className="data-heading" data-colname="datatype">
          Data type
        </div>
        <div className="data-heading" data-colname="actions"></div>

        {data.map((item) => (
          <Fragment key={item.id}>
            <div data-colname="name">{item.title}</div>
            <div data-colname="personal">{item.personal}</div>
            <div data-colname="sensitive">{item.sensitive}</div>
            <div data-colname="repo">{item.repo}</div>
            <div data-colname="datatype">{item.type}</div>
            <div data-colname="actions">
              <button>Edit</button>
            </div>
          </Fragment>
        ))}
      </div>

      <form method="post" enctype="multipart/form-data">
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

export default ResearchOutputs;
