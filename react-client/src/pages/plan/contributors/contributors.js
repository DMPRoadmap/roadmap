import { useEffect, useState, Fragment } from "react";
import { useNavigate, useParams } from "react-router-dom";

import {
  DmpModel,
  Contributor,
  Contact,
  RoadmapAffiliation,
  getContributorRoles,
  getDmp,
  saveDmp,
} from "../../../models.js";

import TextInput from "../../../components/text-input/textInput";
import LookupField from "../../../components/lookup-field.js";
import Checkbox from "../../../components/checkbox/checkbox.js";
import Spinner from "../../../components/spinner";

import "./contributors.scss";

function Contributors() {
  let navigate = useNavigate();

  const { dmpId } = useParams();
  const [dmp, setDmp] = useState();
  const [roles, setRoles] = useState([]);
  const [editIndex, setEditIndex] = useState(null);
  const [contributor, setContributor] = useState(new Contributor({}));


  useEffect(() => {
    getDmp(dmpId).then((initial) => {
      setDmp(initial);
    });

    getContributorRoles().then((data) => {
      setRoles(data);
    });
  }, [dmpId]);


  function handleChange(ev) {
    const { name, value, checked } = ev.target;
    let newContrib = new Contributor(contributor.getData());

    switch (name) {
      case "primary_contact":
        newContrib.contact = checked;
        setContributor(newContrib);
        break;

      case "role":
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
        "role": [],
      }));
    }

    document.getElementById("contributorModal").showModal();
  }

  function closeModal(ev) {
    if (ev) ev.preventDefault();

    setContributor(new Contributor({}));
    document.getElementById("contributorModal").close();
  }

  function handleDeleteContributor(ev) {
    const index = ev.target.value;
    let c = dmp.contributors.get(index);

    if (c.contact) {
      alert("Cannot delete the primary contact. Please choose another contributor to take on this role first");
    } else {
      if (confirm(`Are you sure you want to delete the contributor, ${c.name}?`)) {
        let newDmp = new DmpModel(dmp.getData());
        newDmp.contributors.remove(index);
        setDmp(newDmp);
      }
    }
  }

  function handleSaveContributor(ev) {
    ev.preventDefault();

    const data = new FormData(ev.target);

    let newContrib = new Contributor(contributor.getData());
    newContrib.name = data.get("full_name");
    newContrib.mbox = data.get("email");
    newContrib.setData("contributor_id", {
      "identifier": data.get("orcid"),
      "type": "orcid",
    });
    newContrib.contact = contributor.contact;
    newContrib.commit();

    if (newContrib.isValid()) {
      if (editIndex === null) {
        // NOTE:: Null index indicates a brand new contributor being added
        dmp.contributors.add(newContrib);
      } else {
        dmp.contributors.update(editIndex, newContrib);
      }

      let newDmp = new DmpModel(dmp.getData());
      setDmp(newDmp);
      closeModal();
    } else {
      setContributor(newContrib);
      console.log(newContrib.errors);
    }
  }

  function handleSave(ev) {
    ev.preventDefault();
    saveDmp(dmp).then(() => {
      navigate(`/dashboard/dmp/${dmp.id}`);
    });
  }

  return (
    <>
    {!dmp ? (
      <Spinner isActive={true} message="Fetching contributors…" className="page-loader"/>
    ) : (
      <div id="Contributors">
        <div className="dmpui-heading">
          <h1>Contributors</h1>
        </div>
        <p>
          Tell us about the project contributors for your project and, designate
          the Primary Investigator (PI). You must specify a Primary Investigator
          (PI) at minimum.
        </p>

        <p>
          You must designate one of the contributors as the primary contact. The
          primary contact is the individual responsible for answering questions
          about the project or its research outputs.
        </p>
        <div className="dmpdui-top-actions">
          <div>
            {!dmp.isRegistered && (
              <button className="secondary" onClick={handleModalOpen}>
                Add Contributor
              </button>
            )}
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
                  <div data-colname="role">{item.roleDisplays.join(', ')}</div>
                  <div data-colname="actions" className="form-actions">
                    {!dmp.isRegistered && (
                    <>
                      <button value={index} onClick={handleModalOpen}>
                        Edit
                      </button>

                      <button value={index} onClick={handleDeleteContributor}>
                        Delete
                      </button>
                    </>
                    )}
                  </div>
                </Fragment>
              ))
            : ""}
        </div>

        <dialog id="contributorModal">
          <form method="post" encType="multipart/form-data"
                onSubmit={handleSaveContributor}>
            <div className="form-modal-wrapper">
              <div className="dmpui-form-cols">
                <div className="dmpui-form-col">
                  <TextInput
                    label="Full name"
                    type="text"
                    required="required"
                    name="full_name"
                    id="full_name"
                    inputValue={contributor.name}
                    placeholder=""
                    error={contributor.errors.get("name")}
                  />
                </div>
              </div>

              <div className="dmpui-form-cols">
                <div className="dmpui-form-col">
                  <TextInput
                    label="Email address"
                    type="email"
                    required="required"
                    name="email"
                    id="email"
                    inputValue={contributor.mbox}
                    placeholder=""
                    error={contributor.errors.get("mbox")}
                  />

                  <Checkbox
                    label="Is Primary Contact?"
                    name="primary_contact"
                    id="primaryContact"
                    onChange={handleChange}
                    isChecked={contributor.contact}
                  />
                </div>

                <div className="dmpui-form-col">
                  <TextInput
                    label="ORCID ID"
                    type="text"
                    name="orcid"
                    id="orcid"
                    inputValue={contributor.id}
                    placeholder=""
                    help=""
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
                    error={contributor.errors.get("affiliation")}
                  />
                </div>
              </div>

              <div className="dmpui-form-cols">
                <div className="dmpui-form-col">
                  <div className={"dmpui-field-group"}>
                    <label className="dmpui-field-label">
                      What is this person's role? *
                    </label>

                    <div id="contributorRoles">
                      {contributor.errors.get("role") && (
                        <p className="dmpui-field-error"> {contributor.errors.get("role")} </p>
                      )}
                      {roles.map((role, index) => (
                        <Fragment key={index}>
                          <Checkbox
                            label={role.label}
                            name="role"
                            id={"_role_" + role.value}
                            inputValue={role.value}
                            onChange={handleChange}
                            isChecked={contributor.roles.includes(role.value)}
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

        <form method="post" encType="multipart/form-data" onSubmit={handleSave}>
          <div className="form-actions ">
            <button type="button" onClick={() => navigate(`/dashboard/dmp/${dmp.id}`)}>
              {dmp.isRegistered ? "Back" : "Cancel"}
            </button>
            {!dmp.isRegistered && (
              <button type="submit" className="primary">
                Save &amp; Continue
              </button>
            )}
          </div>
        </form>
      </div>
    )}
    </>
  );
}

export default Contributors;
