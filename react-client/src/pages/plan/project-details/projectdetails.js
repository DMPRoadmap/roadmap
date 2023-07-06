import {
  Link,
  useParams,
  useNavigate,
} from 'react-router-dom';

import {
  useEffect,
  useState,
} from 'react';

import { DmpApi } from '../../../api';

// forms
import TextInput from '../../../components/text-input/textInput';
import TextArea from '../../../components/textarea/textArea';




function ProjectDetails() {
  let navigate = useNavigate();
  const { dmpId } = useParams();
  const [dmp, setDmp] = useState({});


  async function handleSubmit(ev) {
    ev.preventDefault();
    let api = new DmpApi();



    navigate(`/dashboard/dmp/${dmpId}/`);

    /*
        let options = api.getOptions({
          method: "post",
          body: JSON.stringify({
            "dmp": {
              "title": stepData['project_name'],
              "narrative": fileResult,
            }
          }),
        });
    
        fetch(api.getPath('/dmps'), options).then((resp) => {
          api.handleResponse(resp.status);
          return resp.json();
        }).then((data) => {
          let dmp = data.items[0].dmp;
          navigate(`/dashboard/dmp/${dmp.wip_id.identifier}`);
        });
    */


  }

  return (
    <div id="ProjectDetails">

      <div className="dmpui-heading">
        <h1>Plan Details</h1>
      </div>




      <form method="post" enctype="multipart/form-data" onSubmit={handleSubmit}>
        <div className="form-wrapper">


          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Project Name"
                type="text"
                required="required"
                name="project_name"
                id="project_name"
                placeholder="Project Name"
                help="All or part of the project name/title, e.g. 'Particle Physics'"
                error=""
              />
            </div>

            <div className="dmpui-form-col">
              <TextInput
                label="Project Number or ID"
                type="text"
                required="required"
                name="project_id"
                id="project_id"
                placeholder="Project ID"
                help="The Project ID or number provided by your funder"
                error=""
              />
            </div>
          </div>


          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextArea
                label="Project Abstract"
                type="text"
                required="required"
                name="project_abstract"
                id="project_abstract"
                placeholder=""
                help="A short summary of your project."
                error=""
              />
            </div>
          </div>

          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">

              <TextInput
                label="Project Start Date"
                type="date"
                required="required"
                name="start_date"
                id="start_date"
                placeholder=""
                help=""
                error=""
              />
            </div>
            <div className="dmpui-form-col">
              <TextInput
                label="Project End Date"
                type="date"
                required="required"
                name="end_date"
                id="end_date"
                placeholder=""
                help=""
                error=""
              />

            </div>

          </div>

          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">

              <TextInput
                label="Opportunity / Federal award number"
                type="text"
                required="required"
                name="ppportunity_number"
                id="ppportunity_number"
                placeholder="Opportunity number"
                help="The Federal ID number if you have one, or the opportunity number."
                error=""
              />
            </div>
          </div>





        </div>

        <div className="form-actions ">
          <button type="button" onClick={() => navigate(-1)}>Cancel</button>
          <button type="submit" className="primary">
            Save &amp; Continue
          </button>
        </div>
      </form>


    </div>
  )
}

export default ProjectDetails;
