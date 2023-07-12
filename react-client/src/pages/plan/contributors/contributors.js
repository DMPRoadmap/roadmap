import { Link, useNavigate, useParams } from "react-router-dom";
import { useContext, useEffect, useState, Fragment } from "react";
import { DmpApi } from "../../../api.js";

// forms
import TextInput from "../../../components/text-input/textInput";
import TextArea from "../../../components/textarea/textArea";
import "./contributors.scss";

function Contributors() {
  let navigate = useNavigate();

  let contributors = [
    {
      id: "3523535",
      name: "Maria Praetzellis",
      role: "PI",
    },
    {
      id: "3523535",
      name: "Maria Praetzellis",
      role: "PI",
    },
  ];

  return (
    <div id="Contributors">
      <div className="dmpui-heading">
        <h1>Contributors</h1>
      </div>
      <p>
        Tell us more about your project contributors. Tell us about the key
        contributors for your project and designate the Primary Investigator
        (PI).
      </p>
      <p>You must specify a Primary Investigator (PI) at minimum.</p>

      <div className="dmpdui-top-actions">
        <div>
          <button
            className="secondary"
            onClick={() => navigate("/dashboard/dmp/new")}
          >
            Add Contributor
          </button>
        </div>
      </div>

      <div className="dmpdui-list ">
        <div className="data-heading" data-colname="name">
          Name
        </div>
        <div className="data-heading" data-colname="role">
          Role
        </div>
        <div className="data-heading" data-colname="actions"></div>

        {contributors.map((item) => (
          <Fragment key={item.id}>
            <div data-colname="name">{item.name}</div>
            <div data-colname="role">{item.role}</div>
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

export default Contributors;
