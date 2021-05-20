import { Tinymce } from '../../utils/tinymce.js.erb';
import { Select2 } from '../../utils/select2';
import getConstant from '../../constants';
import {
  failCallback,
} from '../answers/edit';
import 'bootstrap-3-typeahead';

$(() => {
  const grantIdField = $('.grant-id-typeahead');
  const grantIdHidden = $('input#plan_grant_number');
  const showSavingMessage = jQuery => jQuery.parents('.question-form').find('[data-status="saving"]').show();
  const hideSavingMessage = jQuery => jQuery.parents('.question-form').find('[data-status="saving"]').hide();
  const showLoadingOverlay = jQuery => jQuery.find('.overlay').show();
  const hideLoadingOverlay = jQuery => jQuery.find('.overlay').hide();
  const toolbar = 'bold italic | bullist numlist | link | table';


  Tinymce.init();
  $('#is_test').click((e) => {
    const DefaultVisibility = $('#plan_default_visibility').val();
    $('#plan_visibility').val($(e.target).is(':checked') ? 'is_test' : DefaultVisibility);
  });

  const showHideDataContact = (el) => {
    if ((el).is(':checked')) {
      $('div.data-contact').fadeOut();
    } else {
      $('div.data-contact').fadeIn();
    }
  };

  $('#show_data_contact').click((e) => {
    showHideDataContact($(e.currentTarget));
  });
  showHideDataContact($('#show_data_contact'));

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

  const grantNumberInfo = grantId => `Grant number: ${grantId}`;

  const setInitialGrantProjectName = () => {
    const grantId = grantIdHidden.val();
    const researchProjects = window.researchProjects;
    const researchProject = researchProjects.find(datum => datum.grant_id === grantId);
    if (researchProject) {
      grantIdField.val(researchProject.description);
    }
  };

  /* eslint-disable */
  const setUpTypeahead = () => {
    if ($('.edit_plan').length) {
      $.get('/research_projects.json', (data) => {
        window.researchProjects = data;
        const descriptionData = $.map(data, datum => datum.description);
        grantIdField.typeahead({ source: descriptionData });
      }).then(() => { setInitialGrantProjectName(); });
      grantIdField.on('change', () => {
        const current = grantIdField.typeahead('getActive');
        if (current) {
          // match or partial match found
          const currentResearchProject = window.researchProjects.find((datum) => {
            const fixString = string => String(string).toLowerCase();
            return fixString(datum.description) === fixString(current);
          });
          if (currentResearchProject) {
            const grantId = currentResearchProject.grant_id;
            $('#grant_number_info').html(grantNumberInfo(grantId));
            grantIdHidden.val(grantId);
          }
        } else {
          $('#grant_number_info').html(grantNumberInfo(''));
          grantIdHidden.val('');
        }
      });
    }
  };
  /* eslint-enable */

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

  toggleCheckboxes($('#priority-guidance-orgs input[type="checkbox"]:checked').map((i, el) => $(el).val()).get());

  /* eslint-disable */
  /*setUpTypeahead();*/
  /* eslint-enable */

  $('body').on('click', '.plan-details .heading-button', (e) => {
    $(e.currentTarget)
      .find('i.fa-chevron-right, i.fa-chevron-down')
      .toggleClass('fa-chevron-right fa-chevron-down');
  });

  Select2.init('.plan-details');

  $('.plan-details form.madmp-fragment').on('submit', (e) => {
    e.preventDefault();
    const target = $(e.target);
    const form = target.closest('form');

    $.ajax({
      method: form.attr('method'),
      url: form.attr('action'),
      data: form.serializeArray(),
      beforeSend: () => {
        showSavingMessage(target);
        showLoadingOverlay(target);
      },
      complete: () => {
        hideSavingMessage(target);
        hideLoadingOverlay(target);
      },
    }).done((data) => {
      form.html(data.question.form);
      form.find('.answer-save-button').prop('disabled', false);
      Tinymce.init({
        toolbar,
      });
      Select2.init('.plan-details');
    }).fail((error) => {
      failCallback(error, target);
    });
  });

  $('.panel-collapse').on('reload.form', (e) => {
    const target = $(e.target);
    if (!target.hasClass('plan-details-content')) {
      return;
    }
    const form = target.find('form');
    const fragmentId = target.find('.fragment-id').val();
    $.ajax({
      method: 'get',
      url: `/madmp_fragments/load_form/${fragmentId}`,
      beforeSend: () => {
        showLoadingOverlay(target);
      },
      complete: () => {
        hideLoadingOverlay(target);
      },
    }).done((data) => {
      form.html(data.question.form);
      form.find('.answer-save-button').prop('disabled', false);
      Tinymce.init({
        toolbar,
      });
      Select2.init('.plan-details');
    }).fail((error) => {
      failCallback(error, target);
    });
  });
});
