import {
  useEffect,
  useState,
  Fragment
} from "react";
import { useNavigate, useParams } from "react-router-dom";

import {
  getDraftDmp,
  getContributorRoles,
  Contributor,
} from "../../../models.js";

import TextInput from "../../../components/text-input/textInput";
import RadioButton from "../../../components/radio/radio";
import LookupField from "../../../components/lookup-field.js";

import "./contributors.scss";


function Contributors() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [roles, setRoles] = useState([]);
  const [defaultRole, setDefaultRole] = useState();
  const [dmp, setDmp] = useState({});
  const [contributor, setContributor] = useState(new Contributor({}));

  useEffect(() => {
    getDraftDmp(dmpId).then(initial => {
      setDmp(initial);
      console.log(initial);
    });

    getContributorRoles().then(data => {
      setRoles(data);
      for (const r of data) {
        if (r.default) {
          setDefaultRole(r.value);
          break;
        }
      }
    });
  }, [dmpId]);


  function handleChange(ev) {
    const {name, value} = ev.target;

    console.log(`Handle Change - ${name}: ${value}`);

    switch (name) {
      case "role":
        contributor.setData("role", [value]);
        setContributor(contributor);
        break;
    }
  }

  function handleModalOpen(id) {
    // TODO:: If there is an id, populate the modal fields.
    if (id) {
      // Load existing contributor (using correct model)
    } else {
      setContributor(new Contributor({}));
    }
    document.getElementById("contributorModal").showModal();
  }

  async function handleSaveContributor(ev) {
    ev.preventDefault();

    console.log("TODO:: Save Contributors");
    console.log("Contributor Role?");
    console.log(contributor.role);

    const data = new FormData(ev.target);
    console.log("Role?");
    console.log(data.get("role"));

    let full_name = data.get("first_name");
    if (data.get("last_name")) full_name += ", " + data.get("last_name");
    contributor.name = full_name;
    contributor.mbox = data.get("email");
    contributor.setData("contributor_id", data.get("orcid"));
    contributor.setData("role", [data.get("role")]);

    console.log(contributor);
    console.log(contributor.role);

    document.getElementById("contributorModal").close();
  }

  function handleCancelModal(ev) {
    // TODO:: Reset the modal form inputs
    ev.preventDefault();
    document.getElementById("contributorModal").close();
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
          <button className="secondary" onClick={() => handleModalOpen()}>
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

        {dmp.contributors ? dmp.contributors.items.map((item) => (
          <Fragment key={item.id}>
            <div data-colname="name">{item.name}</div>
            <div data-colname="role">{item.role}</div>
            <div data-colname="actions">
              <button value={item.id} onClick={() => handleModalOpen(item.id)}>
                Edit
              </button>
            </div>
          </Fragment>
        )) : ""}
      </div>

      <dialog id="contributorModal">
        <form method="post" enctype="multipart/form-data" onSubmit={handleSaveContributor}>
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
                  label="ORCID ID"
                  type="text"
                  required="required"
                  name="orcid"
                  id="orcid"
                  placeholder=""
                  help=""
                  error=""
                />
              </div>
            </div>

            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                <LookupField
                  label="Affiliation"
                  name="affiliation"
                  id="affiliation"
                  required="required"
                  endpoint="affiliations"
                  placeholder=""
                  help="Search for your institution (API)"
                  onChange={handleChange}
                  error=""
                />
              </div>
            </div>

            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                <div className={"dmpui-field-group"}>
                  <label className="dmpui-field-label">
                    What is this person's role? *
                  </label>
                  <p className="dmpui-field-help">Only one per DMP</p>

                  <div onChange={handleChange}>
                    {roles.map((role) => (
                      <Fragment key={role.value}>
                        <RadioButton
                          label={role.label}
                          name="role"
                          inputValue={role.value}
                          checked={role.value === contributor.role}
                        />
                      </Fragment>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="form-actions ">
            <button type="button" onClick={handleCancelModal}>
              Cancel
            </button>
            <button type="submit" className="primary">
              Save &amp; Continue
            </button>
          </div>
        </form>
      </dialog>

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
