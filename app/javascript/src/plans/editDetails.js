import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../utils/autoComplete';
import { Tinymce } from '../utils/tinymce.js';
import toggleConditionalFields from '../utils/conditionalFields';
import getConstant from '../utils/constants';

$(() => {

  const form = $('form.edit_plan');

  if (form.length > 0) {
    Tinymce.init({ selector: 'textarea#plan_description' });
    Tinymce.init({ selector: 'textarea#plan_ethical_issues_description' });

    $('#is_test').click((e) => {
      $('#plan_visibility').val($(e.target).is(':checked') ? 'is_test' : 'privately_visible');
    });

    const ethicalIssues = $('#plan_ethical_issues');
    const funderId = $('#plan_org_id');

    if (ethicalIssues.length > 0) {
      // If the user checks the ethical_issues field then display the other ethics fields
      ethicalIssues.on('change', () => {
        toggleConditionalFields(ethicalIssues, ethicalIssues.prop('checked'));
      }).change();

      toggleConditionalFields(ethicalIssues, ethicalIssues.prop('checked'));
    }
    if (funderId.length > 0) {
      // If the plan has a funder defined then display the other funder fields
      funderId.on('change', () => {
        toggleConditionalFields(funderId, (funderId.val() !== '{"name":""}' && funderId.val() !== ''));
      }).change();

      toggleConditionalFields(funderId, (funderId.val() !== '{"name":""}' && funderId.val() !== ''));
    }

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

  }
});
