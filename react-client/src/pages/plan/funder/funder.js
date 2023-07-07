import {
  Link,
  useParams,
  useNavigate,
} from 'react-router-dom';

import {
  useEffect,
  useState,
} from 'react';

import { DmpApi } from '../../../api.js';


import TextInput from '../../../components/text-input/textInput';
import RadioButton from '../../../components/radio/radio';
import FunderLookup from '../../../components/funder-lookup/FunderLookup.js';


function PlanFunders() {
  let navigate = useNavigate();
  const { dmpId } = useParams();
  const [dmp, setDmp] = useState({});
  const [Funder, setFunder] = React.useState("");
  const [hasFunder, sethasFunder] = React.useState("no");
  const [FunderNotListed, setFunderNotListed] = React.useState("false");
  const [FunderNotListedName, setFunderNotListedName] = React.useState("");



  const handleFunderChange = (e) => {
    setFunder(e.target.value);
  };

  const handleOptionChange = (e) => {
    sethasFunder(e.target.value);

    if (hasFunder === "no") {
      setFunderNotListed("false");
    }

  };


  const handleFunderNotListedChange = (e) => {
    setFunderNotListed(e.target.checked ? "true" : "false");
  };



  useEffect(() => {
    let api = new DmpApi();
    fetch(api.getPath(`/dmps/${dmpId}`)).then((resp) => {
      api.handleResponse(resp);
      return resp.json();
    }).then((data) => {
      setDmp(data.items[0].dmp);
    });
  }, [dmpId]);




  async function handleSave(ev) {
    ev.preventDefault();
    let api = new DmpApi();

    // Collect the form data
    var stepData = {};
    const form = ev.target;
    const formData = new FormData(form);

    formData.forEach((value, key) => stepData[key] = value);

    console.log('DMPS?');
    console.log(dmp);

    console.log('Step Data');
    console.log(stepData);

    console.log(`/dashboard/dmp/${dmpId}/project-search`);

    navigate(`/dashboard/dmp/${dmpId}/project-search`);







    // TODO:: Add the funder to the DMP data
    // This is the expected structure to add to the DMP
    //
    // NOTE:: This data will come from the Funder typeahead input field.
    //
    // {
    //   "project": [{
    //     "funding": [
    //       {
    //         "dmproadmap_project_number": "prj-XYZ987-UCB",
    //         "grant_id": {
    //           "type": "other",
    //           "identifier": "776242"
    //         },
    //         "name": "National Science Foundation",
    //         "funder_id": {
    //           "type": "fundref",
    //           "identifier": "501100002428"
    //         },
    //         "funding_status": "granted",
    //         "dmproadmap_opportunity_number": "Award-123"
    //       }
    //     ]
    //   }]
    // }

    let options = api.getOptions({
      method: "put",
      body: JSON.stringify({ "dmp": dmp }),
    });

    // fetch(api.getPath('/dmps'), options).then((resp) => {
    //   api.handleResponse(resp.status);
    //   return resp.json();
    // }).then((data) => {
    //   let dmp = data.items[0].dmp;
    //   navigate(`/dashboard/dmp/${dmpId}`);
    // });
  }

  return (
    <>
      <div id="funderPage">

        <div className="dmpui-heading">
          <h1>Funder</h1>
        </div>




        <form method="post" enctype="multipart/form-data" onSubmit={handleSave}>

          <div className="form-wrapper">




            <div className="dmpui-form-cols">


              <div className="dmpui-form-col">
                <div
                  className={'dmpui-field-group'}
                >
                  <label className="dmpui-field-label">
                    Do you have a funder?
                  </label>
                  <p className="dmpui-field-help">
                    Is there a funder associated with this project?
                  </p>



                  <div onChange={handleOptionChange}>
                    <RadioButton
                      label="No"
                      name="have_funder"
                      id="have_funder_no"
                      inputValue="no"
                      checked={hasFunder === "no"}
                    />

                    <RadioButton
                      label="Yes, I have a funder"
                      name="have_funder"
                      id="have_funder_yes"
                      inputValue="yes"
                      checked={hasFunder === "yes"}
                    />
                  </div>


                </div>
              </div>
            </div>



            {(hasFunder && hasFunder === "yes") && (

              <div className="dmpui-form-cols">
                <div className="dmpui-form-col">
                  <FunderLookup
                    label="Find funder"
                    inputValue={Funder}
                    name="funder"
                    id="funder"
                    placeholder=""
                    help="Search for your funder by name."
                    onChange={handleFunderChange}
                    error=""
                  />


                  <div className="dmpui-field-checkbox-group not-listed">

                    <input
                      id="id_funder_not_listed"
                      className="dmpui-field-input-checkbox"
                      name="funder_not_listed"
                      value="true"
                      checked={FunderNotListed === "true"}
                      onChange={handleFunderNotListedChange}
                      type="checkbox"
                    />
                    <label htmlFor="id_funder_not_listed" className="checkbox-label">
                      My funder isn't listed
                    </label>
                  </div>
                </div>
              </div>
            )}

            {(FunderNotListed && FunderNotListed === "true" && hasFunder && hasFunder === "yes") && (
              <div className="dmpui-form-cols">
                <div className="dmpui-form-col">
                  <TextInput
                    label="Enter Funders Name"
                    type="text"
                    required="required"
                    name="not_listed_funder_name"
                    id="not_listed_funder_name"
                    inputValue={FunderNotListedName}
                    onChange={e => setFunderNotListedName(e.target.value)}
                    placeholder=""
                    help="If your funder isn't listed, enter their name here."
                    error=""
                  />
                </div>
              </div>
            )}

          </div>

          <div className="form-actions ">
            <button type="button" onClick={() => navigate(-1)}>Cancel</button>
            <button type="submit" className="primary">Save &amp; Continue</button>
          </div>
        </form>



      </div>
    </>
  )
}

export default PlanFunders;
