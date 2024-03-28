import { useEffect, useState, Fragment, useRef } from "react";
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
  const [working, setWorking] = useState(false);
  //This is to handle Contributors errors to display at top of page
  const [errors, setErrors] = useState([]);
  const scrollToErrorRef = useRef(null);

  // Want to scroll users to top of page when the arrive
  // TODO: Add a wrapper to pages to make sure we scroll to top of page when page is loaded
    useEffect(() => {
      window.scrollTo(0,0)
    }, [])
  
  useEffect(() => {
    getDmp(dmpId).then((initial) => {
      // Force the validation to run silently, so that we can detect contribuor
      // errors
      initial.isValid();
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
      const errorDiv = document.getElementById('errors');
      errorDiv.focus();
      errorDiv.scrollIntoView();
    }
  }

  /**
   * Takes dmp.errors map and returns the "contributors" error
   * @param {*} map 
   * @returns {string}
   */
  const findContributorsError = (map) => {
    const entriesArray = Array.from(map.entries());
    const entry = entriesArray.find(([key, value]) => key === "contributors");
    return entry ? entry[1] : '';
  }

  function handleSave(ev) {
    ev.preventDefault();
    setWorking(true);

    // Force the validation to run silently, so that we can detect contribuor
    // errors
    if (!dmp.isValid()) {
      if (dmp.errors.has("contributors")) {
        // We set a separate Errors state that will trigger a re-render of the body
        // when there are errors, without triggring an update to the dmp state. Otherwise, the
        // list of Contributors is empty when there are errors.
        const contributorsErrors = findContributorsError(dmp.errors);
        if (contributorsErrors.length > 0) {
          setErrors(prevErrors => [...prevErrors, contributorsErrors]);
          setWorking(false);
          if (scrollToErrorRef.current.scrollIntoView({ behavior: 'smooth' }));
          return;
        }
        setWorking(false);
        return
      }
    }

    saveDmp(dmp).then(() => {
      navigate(`/dashboard/dmp/${dmp.id}`);
    }).catch((e) => {
      console.log("Error saving DMP");
      console.log(e);
      setWorking(false);
    });
  }

  return (
    <>
      {!dmp ? (
        <Spinner isActive={true} message="Fetching contributors…" className="page-loader" />
      ) : (
        <div id="Contributors" ref={scrollToErrorRef}>
          <div className="dmpui-heading">
            <h1>Contributors</h1>
              {errors && errors.map(err => {
                return (
                  <div key={err} className="dmpui-field-error">{err}</div>
                )
              })}
          </div>
          <p>
            Tell us about the project contributors for your project and, designate
            the Principal Investigator (PI). You must specify a Principal Investigator
            (PI) at minimum.
          </p>

          <p>
            You must designate one of the contributors as the primary contact. The
            primary contact is the individual responsible for answering questions
            about the project or its research outputs.
          </p>
          <div className="dmpdui-top-actions">
            <div>
              <button className="secondary" onClick={handleModalOpen}>
                Add Contributor
              </button>
            </div>
          </div>

          <div className="table-container">
            <div className="table-wrapper">
              {dmp.contributors && dmp.contributors.items.length > 0 ? (
                <table className="dmpui-table">
                  <thead>
                    <tr>
                      <th scope="col" className="table-header-name data-heading">
                        Name
                      </th>
                      <th scope="col" className="table-header-name data-heading">
                        Role
                      </th>
                      <th scope="col" className="table-header-name data-heading">
                        Actions
                      </th>
                    </tr>
                  </thead>
                  <tbody className="table-body">
                    {dmp.contributors.items.map((item, index) => (
                      <tr key={index}>
                        <td className="table-data-name" data-colname="name" id={"Contributor-" + index}>
                          {item.name}
                        </td>
                        <td className="table-data-name" data-colname="role">
                          {item.roleDisplays.join(', ')}
                        </td>
                        <td className="table-data-name table-data-actions" data-colname="actions">
                          <button
                            className="edit-button"
                            id={"editContributor-" + index}
                            aria-labelledby={"editContributor-" + index + " " + "Contributor-" + index}
                            value={index}
                            onClick={handleModalOpen}>
                            Edit
                          </button>

                          <button
                            className="delete-button"
                            id={"deleteContributor-" + index}
                            aria-labelledby={"deleteContributor-" + index + " " + "Contributor-" + index}
                            value={index}
                            onClick={handleDeleteContributor}>
                            Delete
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              ) : (
                <div className="no-dmp-message mt-5">
                  <h3>No Contributors Found</h3>
                  <p>
                    No contributors were found. Please add some contributors to display them here.
                  </p>
                </div>
              )}
            </div>
          </div>


          <dialog id="contributorModal">
            <form method="post" encType="multipart/form-data"
              onSubmit={handleSaveContributor}>
              <div className="form-modal-wrapper">



                <div className="dmpui-form-cols" tabIndex={-1} id="errors">
                  {contributor.errors && contributor.errors.size > 0 && (
                    <div className="dmpui-form-col" >
                      <p>There has been some errors</p>
                      <ul>
                        {Array.from(contributor.errors).map(([key, value]) => (
                          <li key={key} className="dmpui-field-error">{value}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>


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
                    <fieldset className={"dmpui-field-group required"}>
                      <legend className="dmpui-field-label">
                        What is this person's role?
                      </legend>

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
                              isChecked={contributor.roles.filter(str => str.includes(role.value)).length > 0}
                            />
                          </Fragment>
                        ))}
                      </div>
                    </fieldset>
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
              {working ? (
                <Spinner isActive={working} message="" className="empty-list" />
              ) : (
                <>
                  <button type="button" onClick={() => navigate(`/dashboard/dmp/${dmp.id}`)}>
                    {dmp.isRegistered ? "Back" : "Cancel"}
                  </button>
                  <button type="submit" className="primary">
                    {dmp.isRegistered ? "Update" : "Save & Continue"}
                  </button>
                </>
              )}
            </div>
          </form>
        </div>
      )}
    </>
  );
}

export default Contributors;
