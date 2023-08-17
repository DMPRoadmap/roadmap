import {
  useEffect,
  useState,
  Fragment
} from "react";
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
import RadioButton from "../../../components/radio/radio";
import LookupField from "../../../components/lookup-field.js";

import "./contributors.scss";


function Contributors() {
  let navigate = useNavigate();

  const {dmpId} = useParams();
  const [roles, setRoles] = useState([]);
  const [editIndex, setEditIndex] = useState(null);
  const [selectedRole, setSelectedRole] = useState();
  const [defaultRole, setDefaultRole] = useState();
  const [dmp, setDmp] = useState({});
  const [contributor, setContributor] = useState(new Contributor({}));

  var affiliation;

  useEffect(() => {
    getDraftDmp(dmpId).then(initial => {
      setDmp(initial);
    });

    getContributorRoles().then(data => {
      setRoles(data);
      for (const r of data) {
        if (r.default) {
          setDefaultRole(r.value);
          setSelectedRole(r.value);
          break;
        }
      }
    });
  }, [dmpId]);


  function handleChange(ev) {
    const {name, value} = ev.target;

    switch (name) {
      case "role":
        setSelectedRole(value);
        break;

      case "affiliation":
        if (ev.data) {
          affiliation = new RoadmapAffiliation(ev.data);
        }
        break;
    }
  }


  function handleModalOpen(ev) {
    ev.preventDefault();

    const index = ev.target.value;
    if ((index !== "") && (typeof index !== "undefined") ) {
      setEditIndex(index);
      let newContrib = dmp.contributors.get(index);
      setContributor(newContrib);
    } else {
      setEditIndex(null);
      setContributor(new Contributor({}));
    }

    document.getElementById("contributorModal").showModal();
  }


  function handleSaveContributor(ev) {
    ev.preventDefault();

    const data = new FormData(ev.target);

    let full_name = data.get("first_name");
    if (data.get("last_name")) full_name += ", " + data.get("last_name");
    contributor.name = full_name;
    contributor.mbox = data.get("email");
    contributor.setData("contributor_id.identifier", data.get("orcid"));
    contributor.setData("role", [data.get("role")]);

    if (affiliation) { contributor.affiliation = affiliation; }
    contributor.commit();

    if (typeof editIndex === "null") {
      // NOTE:: Null index indicates a brand new contributor being added
      dmp.contributors.add(contributor);
    } else {
      dmp.contributors.update(editIndex, contributor);
    }
    dmp.commit();
    let newDmp = new DmpModel(dmp.getData());
    setDmp(newDmp);

    document.getElementById("contributorModal").close();
  }

  function handleCancelModal(ev) {
    ev.preventDefault();
    setContributor(new Contributor({}));
    document.getElementById("contributorModal").close();
  }

  function handleSave(ev) {
    ev.preventDefault();
    dmp.commit();
    saveDraftDmp(dmp).then((savedDmp) => {
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

        {dmp.contributors ? dmp.contributors.items.map((item, index) => (
          <Fragment key={index}>
            <div data-colname="name">{item.name}</div>
            <div data-colname="role">{item.roleDisplay}</div>
            <div data-colname="actions">
              <button value={index} onClick={handleModalOpen}>
                Edit
              </button>
            </div>
          </Fragment>
        )) : ""}
      </div>

      <dialog id="contributorModal">
        <form method="post"
              enctype="multipart/form-data"
              onSubmit={handleSaveContributor}>
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
                    {roles.map((role, index) => (
                      <Fragment key={index}>
                        <RadioButton
                          label={role.label}
                          name="role"
                          id={"_role_" + role.value}
                          inputValue={role.value}
                          checked={role.value === selectedRole}
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
              {(editIndex === null) ? "Add" : "Save Changes"}
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
