import { Link, useNavigate, useParams } from "react-router-dom";
import { useContext, useEffect, useState, Fragment } from "react";
import { DmpApi } from "../../../api.js";

// forms
import TextInput from "../../../components/text-input/textInput";
import TextArea from "../../../components/textarea/textArea";
import Modal from "../../../components/modal/modal";
import "./contributors.scss";

function Contributors() {
  let navigate = useNavigate();
  const [show, setShow] = useState(false);

  console.log("Show Contributors Modal: ", show);
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

  async function handleSave(ev) {
    ev.preventDefault();

    console.log("Save Contributors");
    alert("save contributors");
    setShow(false);
  }

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
          <button className="secondary" onClick={() => setShow(true)}>
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
              <button onClick={() => setShow(true)}>Edit</button>
            </div>
          </Fragment>
        ))}
      </div>

      <Modal title="Add Contributor" onClose={() => setShow(false)} show={show}>
        <form method="post" enctype="multipart/form-data" onSubmit={handleSave}>
          <div className="form-modal-wrapper">
            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                <TextInput
                  label="First name"
                  type="text"
                  required="required"
                  name="first_name"
                  id="first_name"
                  placeholder=""
                  help=""
                  error=""
                />
              </div>

              <div className="dmpui-form-col">
                <TextInput
                  label="Last name"
                  type="text"
                  required="required"
                  name="last_name"
                  id="last_name"
                  placeholder=""
                  help=""
                  error=""
                />
              </div>
            </div>

            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                <TextInput
                  label="Email addresss"
                  type="email"
                  required="required"
                  name="email"
                  id="email"
                  placeholder=""
                  help=""
                  error=""
                />
              </div>

              <div className="dmpui-form-col">
                <TextInput
                  label="Affiliation"
                  type="text"
                  required="required"
                  name="affiliation"
                  id="affiliation"
                  placeholder=""
                  help=""
                  error=""
                />
              </div>
            </div>

            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">Role</div>

              <div className="dmpui-form-col"></div>
            </div>
          </div>

          <div className="form-actions ">
            <button type="button" onClick={() => setShow(false)}>
              Cancel
            </button>
            <button type="submit" className="primary">
              Save &amp; Continue
            </button>
          </div>
        </form>
      </Modal>

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
