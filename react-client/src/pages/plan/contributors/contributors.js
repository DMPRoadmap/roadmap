import { useEffect, useState, Fragment } from "react";
import { useNavigate, useParams } from "react-router-dom";

import {
  DmpModel,
  Contributor,
  RoadmapAffiliation,
  getContributorRoles,
  getDraftDmp,
  saveDraftDmp,
} from "../../../models.js";

import TextInput from "../../../components/text-input/textInput";
import LookupField from "../../../components/lookup-field.js";
import Checkbox from "../../../components/checkbox/checkbox.js";

import "./contributors.scss";

function Contributors() {
  let navigate = useNavigate();

  const { dmpId } = useParams();
  const [roles, setRoles] = useState([]);
  const [editIndex, setEditIndex] = useState(null);
  const [defaultRole, setDefaultRole] = useState();
  const [dmp, setDmp] = useState({});
  const [contributor, setContributor] = useState(new Contributor({}));

  useEffect(() => {
    getDraftDmp(dmpId).then((initial) => {
      setDmp(initial);
    });

    getContributorRoles().then((data) => {
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
    const { name, value, checked } = ev.target;
    let newContrib = new Contributor(contributor.getData());

    switch (name) {
      case "role":
        console.log(`Role? ${value}; Checked? ${checked}`);
        if (checked) {
          newContrib.addRole(value);
        } else {
          newContrib.removeRole(value);
        }
        setContributor(newContrib);
        break;

      case "affiliation":
        if (ev.data) {
          newContrib.affiliation = new RoadmapAffiliation(ev.data);
        } else {
          newContrib.affiliation.name = value;
        }
        setContributor(newContrib);
        break;
    }
  }

  function handleModalOpen(ev) {
    ev.preventDefault();

    const index = ev.target.value;
    if (index !== "" && typeof index !== "undefined") {
      setEditIndex(index);
      let newContrib = dmp.contributors.get(index);
      setContributor(newContrib);
    } else {
      setEditIndex(null);
      setContributor(new Contributor({
        "role": [defaultRole]
      }));
    }

    document.getElementById("contributorModal").showModal();
  }

  function closeModal(ev) {
    if (ev) ev.preventDefault();

    setContributor(new Contributor({}));
    document.getElementById("contributorModal").close();
  }

  function handleSaveContributor(ev) {
    ev.preventDefault();

    const data = new FormData(ev.target);

    let full_name = data.get("first_name");
    if (data.get("last_name")) full_name += ", " + data.get("last_name");
    contributor.name = full_name;
    contributor.mbox = data.get("email");
    contributor.setData("contributor_id.identifier", data.get("orcid"));
    contributor.commit();

    if (editIndex === null) {
      // NOTE:: Null index indicates a brand new contributor being added
      dmp.contributors.add(contributor);
    } else {
      dmp.contributors.update(editIndex, contributor);
    }
    dmp.commit();
    let newDmp = new DmpModel(dmp.getData());
    setDmp(newDmp);

    closeModal();
  }

  function handleSave(ev) {
    ev.preventDefault();
    saveDraftDmp(dmp).then(() => {
      navigate(-1);
    });
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
          <button className="secondary" onClick={handleModalOpen}>
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

        {dmp.contributors
          ? dmp.contributors.items.map((item, index) => (
              <Fragment key={index}>
                <div data-colname="name">{item.name}</div>
                <div data-colname="role">{item.roleDisplay}</div>
                <div data-colname="actions">
                  <button value={index} onClick={handleModalOpen}>
                    Edit
                  </button>
                </div>
              </Fragment>
            ))
          : ""}
      </div>

      <dialog id="contributorModal">
        <form
          method="post"
          enctype="multipart/form-data"
          onSubmit={handleSaveContributor}
        >
          <div className="form-modal-wrapper">
            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                <TextInput
                  label="First name"
                  type="text"
                  required="required"
                  name="first_name"
                  id="first_name"
                  inputValue={contributor.first_name}
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
                  inputValue={contributor.last_name}
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
                  inputValue={contributor.mbox}
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
                  inputValue={contributor.id}
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
                  inputValue={contributor.affiliation.name}
                  onChange={handleChange}
                />
              </div>
            </div>

            <div className="dmpui-form-cols">
              <div className="dmpui-form-col">
                <div className={"dmpui-field-group"}>
                  <label className="dmpui-field-label">
                    What is this person's role? *
                  </label>

                  <div onChange={handleChange}>
                    {roles.map((role, index) => (
                      <Fragment key={index}>
                        <Checkbox
                          label={role.label}
                          name="role"
                          id={"_role_" + role.value}
                          inputValue={role.value}
                          checked={contributor.roles.includes(role.value)}
                        />
                      </Fragment>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div className="form-actions ">
            <button type="button" onClick={closeModal}>
              Cancel
            </button>
            <button type="submit" className="primary">
              {editIndex === null ? "Add" : "Update"}
            </button>
          </div>
        </form>
      </dialog>

      <form method="post" enctype="multipart/form-data" onSubmit={handleSave}>
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
