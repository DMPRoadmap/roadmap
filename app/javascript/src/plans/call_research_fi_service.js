/* makes call to the research.fi API on the user entering a project funder number in the Grant number/url field on the Project Details tab of a plan */

$(() => {
  $('#call_research_fi_api_btn').on('click', (e) => {
    var projectFunderNumberVal = $('#plan_grant_value').val();
    // check if funding decision number has been entered by user
    if (
      projectFunderNumberVal == '' || 
      projectFunderNumberVal == null ||
      projectFunderNumberVal == undefined
    ) {
      // user did not enter a funding-decision-number
      // inform user of outcome with flash message
      $('#notification-area').removeClass();
      $('#notification-area').addClass("notification-area alert alert-warning d-block");
      $('#notification-area').attr('role', 'alert');
      var spans = $('#notification-area span');
      for (var i = 0; i < spans.length; i++) {
        spans[i].remove(); 
      };
      $('#notification-area').append('<span class="aria-only">Notice: </span>');
      $('#notification-area').append('<span>Please enter a funding decision number.</span>');
    } else {
      // user entered a funding decision number so try to retrieve decision 
      // from research.fi
      $.ajax({
        type: 'GET',
        url: '/research_fi_service/get_funding_decision/' + projectFunderNumberVal,
        headers: {'Accept': 'application/json'},
        complete: (jqXHR, textStatus) => {
          research_fi_response = jqXHR.responseJSON;
          research_fi_status_code = research_fi_response['research_fi_status_code'];
          if (research_fi_status_code[0] === '2') {
            // call was successful
            // get the data
            research_fi_data = research_fi_response['research_fi_data'];
            if (research_fi_data.length > 0) {
              // project found in research.fi database
              funding_decision = research_fi_data[0]
              
              // set project title (Tuuli Team prefers English for DMPs)
              if (('nameEn' in funding_decision) || ('nameFi' in funding_decision)) {
                if ('nameEn' in funding_decision) {
                  project_title = funding_decision['nameEn'];
                } else {
                  project_title = funding_decision['nameFi'];
                }
                $('#plan_title').val(project_title);
              }
  
              // set project abstract (Tuuli Team prefers English for DMPs)
              if (('descriptionEn' in funding_decision) || ('descriptionFi' in funding_decision)) {
                if ('descriptionEn' in funding_decision) {
                  project_abstract = funding_decision['descriptionEn'];
                } else {
                  project_abstract = funding_decision['descriptionFi'];
                }
                project_abstract = '<p>' + project_abstract + '</p>';
                var iframe_content = $('#plan_description_ifr').contents().find('body#tinymce');
                iframe_content.html(project_abstract);
              }
  
              // set research domain
              if ('fieldsOfScience' in funding_decision) {
                if (funding_decision['fieldsOfScience'].length > 0) {
                  fields_of_science = funding_decision['fieldsOfScience'][0];
                  if ('nameEn' in fields_of_science) {
                    fields_of_science_name = fields_of_science['nameEn'];
                    field_of_science_name_sanitised = fields_of_science_name.toLowerCase().replace('-', '');
                    var research_domain_field = $('#plan_research_domain_id');
                    for (var i = 0; i < research_domain_field[0].options.length; i++) {
                      research_domain_option_sanitised = research_domain_field[0].options[i].text.toLowerCase().replace('-', '');
                      if (
                        research_domain_option_sanitised.includes(field_of_science_name_sanitised) ||
                        field_of_science_name_sanitised.includes(research_domain_option_sanitised)
                        ) {
                        research_domain_field.val(parseInt( research_domain_field[0].options[i].value));
                      }
                    }
                  } 
                }
              }
  
              // set project start
              if ('fundingStartDate' in funding_decision) {
                project_start = funding_decision['fundingStartDate'];
                project_start = project_start.split('T')[0];
                $('#plan_start_date').val(project_start);
              }
  
              // set project end if present
              if ('fundingEndDate' in funding_decision) {
                project_end = funding_decision['fundingEndDate'];
                project_end = project_end.split('T')[0];
                $('#plan_end_date').val(project_end);
              }
  
              // set funder
              if ('funder' in funding_decision) {
                var funding_decision_funder = funding_decision['funder'];
                if ('nameEn' in funding_decision_funder) {
                  var funding_decision_funder_en = funding_decision_funder['nameEn'];
                  var funding_decision_funder_en_sanitised = funding_decision_funder_en.toLowerCase().replace('-', '');
                  var funders_as_string = $('#plan_funder_org_crosswalk')[0].value;
                  var funders_as_array_of_objects = JSON.parse(funders_as_string);
                  for (var i = 0; i < funders_as_array_of_objects.length; i++) { 
                    // check if retrieved funder is an approximate match for any of the funders
                    // we have associated with this template
                    funder_name_sanitised = funders_as_array_of_objects[i].name.toLowerCase().replace('-', '');
                    funder_sort_name_sanitised = funders_as_array_of_objects[i].sort_name.toLowerCase().replace('-', '');
                    if (
                      funder_name_sanitised.includes(funding_decision_funder_en_sanitised) || 
                      funder_sort_name_sanitised.includes(funding_decision_funder_en_sanitised) ||
                      funding_decision_funder_en_sanitised.includes(funder_name_sanitised) ||
                      funding_decision_funder_en_sanitised.includes(funder_sort_name_sanitised)               
                      ) {
                      // set internal value of funder field
                      $('#plan_funder_id')[0].value = (JSON.stringify(funders_as_array_of_objects[i]));
                      // set display value of funder field
                      $('#plan_funder_org_name.form-control.autocomplete.ui-autocomplete-input')[0].value = funders_as_array_of_objects[i].name;
                      break;
                    }
                  }
                }
              } 
              
              // set funding status
              $('#plan_funding_status').val('funded');
  
              // inform user with flash message
              $('#notification-area').removeClass();
              $('#notification-area').addClass("notification-area alert alert-info d-block");
              $('#notification-area').attr('role', 'status');
              var spans = $('#notification-area span');
              for (var i = 0; i < spans.length; i++) {
              spans[i].remove(); 
              };
              $('#notification-area').append('<span class="aria-only">Notice: </span>');
              $('#notification-area').append('<span>Project details successfully retrieved</span>');
  
            } else {
              // project not found in research.fi database
              // inform user with flash message
              $('#notification-area').removeClass();
              $('#notification-area').addClass("notification-area alert alert-warning d-block");
              $('#notification-area').attr('role', 'alert');
              var spans = $('#notification-area span');
              for (var i = 0; i < spans.length; i++) {
                spans[i].remove(); 
              };
              $('#notification-area').append('<span class="aria-only">Notice: </span>');
              $('#notification-area').append('<span>Project was not found in research.fi database. Please check that the funder project number you entered is correct.</span>');
            }
          } else if (research_fi_status_code[0] === '4') {
            // call was unsuccessful, problem with call made by client
            // inform user of outcome with flash message
            $('#notification-area').removeClass();
            $('#notification-area').addClass("notification-area alert alert-warning d-block");
            $('#notification-area').attr('role', 'alert');
            var spans = $('#notification-area span');
            for (var i = 0; i < spans.length; i++) {
              spans[i].remove(); 
            };
            $('#notification-area').append('<span class="aria-only">Notice: </span>');
            $('#notification-area').append('<span>There was a problem with the request made to the research.fi database, and so the project details could not be retrieved.</span>');
          } else if (research_fi_status_code[0] === '5') {
            // call was unsuccessful, problem with server
            // inform user of outcome with flash message
            $('#notification-area').removeClass();
            $('#notification-area').addClass("notification-area alert alert-warning d-block");
            $('#notification-area').attr('role', 'alert');
            var spans = $('#notification-area span');
            for (var i = 0; i < spans.length; i++) {
              spans[i].remove(); 
            };
            $('#notification-area').append('<span class="aria-only">Notice: </span>');
            $('#notification-area').append('<span>There was a problem in the research.fi database, and so the project details could not be retrieved.</span>');
          } else {
            // call was unsuccessful, reason not clear
            // inform user of outcome with flash message
            $('#notification-area').removeClass();
            $('#notification-area').addClass("notification-area alert alert-warning d-block");
            $('#notification-area').attr('role', 'alert');
            var spans = $('#notification-area span');
            for (var i = 0; i < spans.length; i++) {
              spans[i].remove(); 
            };
            $('#notification-area').append('<span class="aria-only">Notice: </span>');
            $('#notification-area').append('<span>There was a problem in the system, and so the project details could not be retrieved.</span>');
          }
        }
      })
    }
  });
});