import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../utils/autoComplete';
import { Tinymce } from '../utils/tinymce.js.erb';
import getConstant from '../utils/constants';

$(() => {
  const grantIdField = $('.grant-id-typeahead');
  const grantIdHidden = $('input#plan_grant_value');

  Tinymce.init();
  $('#is_test').click((e) => {
    $('#plan_visibility').val($(e.target).is(':checked') ? 'is_test' : 'privately_visible');
  });

  // Toggle the disabled flags
  const toggleCheckboxes = (selections) => {
    $('#priority-guidance-orgs, #other-guidance-orgs').find('input[type="checkbox"]').each((i, el) => {
      const checkbox = $(el);
      if (selections.length >= getConstant('MAX_NUMBER_GUIDANCE_SELECTIONS')) {
        if (checkbox.is(':checked')) {
          checkbox.removeAttr('disabled');
        } else {
          checkbox.prop('disabled', true);
        }
      } else {
        checkbox.prop('disabled', false);
      }
    });
  };

  // Keep the modal window's guidance selections in line with selections on the main page
  const syncGuidance = (ctx) => {
    const currentList = $(ctx);
    const otherList = (currentList.attr('id') === 'priority-guidance-orgs' ? $('#other-guidance-orgs') : $('#priority-guidance-orgs'));
    const selections = currentList.find('input[type="checkbox"]:checked').map((i, el) => $(el).val()).get();
    otherList.find('input[type="checkbox"]').each((i, el) => {
      const checkbox = $(el);
      // Toggle the checked flag to match the current guidance list
      if (selections.indexOf(checkbox.val()) >= 0) {
        checkbox.prop('checked', true);
      } else {
        checkbox.prop('checked', false);
      }
    });
    toggleCheckboxes(selections);
  };

  const grantNumberInfo = (grantId) => `Grant number: ${grantId}`;

  const setInitialGrantProjectName = () => {
    const grantId = grantIdHidden.val();
    const researchProjects = window.researchProjects;
    const researchProject = researchProjects.find((datum) => datum.grant_id === grantId);
    if (researchProject) {
      grantIdField.val(researchProject.description);
    }
  };

  const setUpTypeahead = () => {
    if ($('.edit_plan').length) {
      // TODO: Convert this over so that it just loads in the controller?
      //       Follow this pattern:
      // if ($('#org-details-org-controls').length > 0) {
      //   initAutocomplete('#org-details-org-controls .autocomplete');
      // }

      $.get('/research_projects.json', (data) => {
        window.researchProjects = data;
        const descriptionData = $.map((dataIn, datum) => datum.description);
        grantIdField.typeahead({ source: descriptionData });
      }).then(() => { setInitialGrantProjectName(); });

      grantIdField.on('change', () => {
        const current = grantIdField.typeahead('getActive');
        if (current) {
          // match or partial match found
          const currentResearchProject = window.researchProjects.find((datum) => {
            const fixString = (string) => String(string).toLowerCase();
            return fixString(datum.description) === fixString(current);
          });
          if (currentResearchProject) {
            const grantId = currentResearchProject.grant_id;
            $('#grant_number_info').html(grantNumberInfo(grantId));
            if (grantId.length > 0) {
              grantIdHidden.val(grantId);
            } else {
              grantIdHidden.val(grantIdField.val());
            }
          }
        } else {
          $('#grant_number_info').html(grantNumberInfo(''));
          grantIdHidden.val(grantIdField.val());
        }
      });
    }
  };

  $('#other-guidance-orgs').find('input[type="checkbox"]').click((e) => {
    const checkbox = $(e.target);
    // Since this is the modal window, copy any selections over to the priority list
    if (checkbox.is(':checked')) {
      const priorityList = $('#priority-guidance-orgs');
      if (priorityList.find(`input[value="${checkbox.val()}"]`).length <= 0) {
        const li = checkbox.closest('li');
        // If its a subgroup copy the whole group otherwise just copy the line
        if (li.children('.sublist').length > 0) {
          priorityList.append(li.closest('ul').parent().clone());
        } else {
          priorityList.append(li.clone());
        }
      }
    }
    syncGuidance(checkbox.closest('ul[id]'));
  });

  $('#priority-guidance-orgs').find('input[type="checkbox"]').click((e) => {
    syncGuidance($(e.target).closest('ul[id]'));
  });

  initAutocomplete('#funder-org-controls .autocomplete');
  // Scrub out the large arrays of data used for the Org Selector JS so that they
  // are not a part of the form submissiomn
  scrubOrgSelectionParamsOnSubmit('form.edit_plan');

  toggleCheckboxes($('#priority-guidance-orgs input[type="checkbox"]:checked').map((i, el) => $(el).val()).get());

  setUpTypeahead();
});
