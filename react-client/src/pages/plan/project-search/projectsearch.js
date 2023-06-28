import useContext from 'react';
import { useNavigate } from 'react-router-dom';
import { DmpApi } from '../../../api';

// forms
import TextInput from '../../../components/text-input/textInput';
import TextArea from '../../../components/textarea/textArea';




function ProjectSearch() {
  let navigate = useNavigate();
  let dmpData = {};

  async function handleSubmit(ev) {
    ev.preventDefault();
    let api = new DmpApi();

    // Collect the form data
    var stepData = {};
    const form = ev.target;
    const formData = new FormData(form);

    formData.forEach((value, key) => stepData[key] = value);

    const fileResult = await api.getFileDataURL(stepData['project_pdf'])

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
  }

  return (
    <div id="ProjectSearch">

      <div className="dmpui-heading">
        <h1>Plan Details</h1>
      </div>


      <div className="dmpui-search-form-container">
        <h2>
          Find your project
        </h2>
        <p>
          Tell us more about your project. Enter as much info below as you can. We'll use this to locate key information.
        </p>



        <form method="post" enctype="multipart/form-data">
          <div className="dmpui-form-cols">
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
          </div>

          <div className="dmpui-form-cols">
            <div className="dmpui-form-col">
              <TextInput
                label="Principle Investigator (PI)"
                type="text"
                required="required"
                name="principle_investigator"
                id="principle_investigator"
                placeholder=""
                help="PI Names or Profile IDs, semicolon ';' separated"
                error=""
              />
            </div>

            <div className="dmpui-form-col">
              <TextInput
                label="Award Year"
                type="text"
                required="required"
                name="award_year"
                id="award_year"
                placeholder="Award Year"
                help="e.g. 2020"
                error=""
              />
            </div>
          </div>
        </form>






      </div>






      <form method="post" enctype="multipart/form-data" onSubmit={handleSubmit}>
        <div className="form-wrapper">


        </div>


        <div className="form-actions ">
          <button type="button" onClick={() => navigate(-1)}>Cancel</button>
          <button type="submit" className="primary">
            Save &amp; Continue
          </button>
        </div>
      </form>


    </div >
  )
}

export default ProjectSearch;
