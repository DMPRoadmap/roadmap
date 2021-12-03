import {
  doneCallback,
  failCallback,
} from '../answers/edit';
import { Tinymce } from '../../utils/tinymce.js.erb';
import { Select2 } from '../../utils/select2';
import expandCollapseAll from '../../utils/expandCollapseAll';
// import TimeagoFactory from '../../utils/timeagoFactory';

$(() => {
  // Attach handlers for the expand/collapse all accordions
  expandCollapseAll();

  const showSavingMessage = jQuery => jQuery.parents('.question-form').find('[data-status="saving"]').show();
  const hideSavingMessage = jQuery => jQuery.parents('.question-form').find('[data-status="saving"]').hide();
  const showLoadingOverlay = jQuery => jQuery.find('.overlay').show();
  const hideLoadingOverlay = jQuery => jQuery.find('.overlay').hide();
  const toolbar = 'bold italic underline | fontsizeselect forecolor | bullist numlist | link | table';
  const displayRunTabs = (formData, questionId, researchOutputId) => {
    if (formData) {
      $(`#runs-${questionId}-research-output-${researchOutputId} .run-zone`).html(formData);
      $(`#collapse-${questionId}-research-output-${researchOutputId} .runs-tab`).show();
    } else {
      $(`#runs-${questionId}-research-output-${researchOutputId} .run-zone`).html('');
      $(`#collapse-${questionId}-research-output-${researchOutputId} .runs-tab`).hide();
      $(`a[href="#notes-${questionId}-research-output-${researchOutputId}"]`).tab('show');
    }
  };

  $('.panel-collapse').on('shown.bs.collapse reload.form', (e) => {
    const target = $(e.target);
    const fragmentId = target.find('.fragment-id').val();
    if (!target.hasClass('fragment-content')) {
      return;
    }
    if (fragmentId) {
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
        doneCallback(data, target);
        displayRunTabs(data.question.form_run, data.question.id, data.research_output.id);
        Tinymce.init({
          selector: `#research_output_${data.research_output.id}_section_${data.section.id} .note`,
          toolbar,
        });
        target.find('.toggle-guidance-section').removeClass('disabled');
        Select2.init(`#answer-form-${data.question.id}-research-output-${data.research_output.id}`);
      }).fail((error) => {
        failCallback(error, target);
      });
    } else {
      const form = target.find('.new-fragment');
      if (form.length === 0) return;

      $.ajax({
        method: 'get',
        url: '/madmp_fragments/load_new_form',
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
        doneCallback(data, target);
        Tinymce.init({
          selector: `#research_output_${data.research_output.id}_section_${data.section.id} .note`,
          toolbar,
        });
        Select2.init(`#answer-form-${data.question.id}-research-output-${data.research_output.id}`);
        target.find('.schema_picker').data('fragment-id', data.fragment_id);
        target.find('.toggle-guidance-section').removeClass('disabled');
      }).fail((error) => {
        failCallback(error, target);
      });
    }
  });

  $('.panel-collapse').on('hide.bs.collapse.fragment-content', (e) => {
    const target = $(e.target);
    if (target.find('.guidance-section').is(':visible')) {
      target.find('.toggle-guidance-section').trigger('click');
    }
    target.find('.toggle-guidance-section').addClass('disabled');
  });

  $('body').on('click', '.question .heading-button', (e) => {
    $(e.currentTarget)
      .find('i.fa-chevron-right, i.fa-chevron-down')
      .toggleClass('fa-chevron-right fa-chevron-down');
  });


  // When selecting a new form in the form selector, sends the new schema and
  // fragment id to the server
  $(document).on('change', '.schema_picker', (e) => {
    const target = $(e.target);
    const schemaId = target.val();
    const fragmentId = target.data('fragment-id');
    const form = target.parents('.question').find('.form-answer');
    $.ajax({
      url: `/madmp_fragments/change_schema/${fragmentId}?schema_id=${schemaId}`,
      method: 'get',
      beforeSend: () => {
        showSavingMessage(form);
        showLoadingOverlay(form);
      },
      complete: () => {
        hideSavingMessage(form);
        hideLoadingOverlay(form);
      },
    }).done((data) => {
      doneCallback(data, target);
      displayRunTabs(data.question.form_run, data.question.id, data.research_output.id);
      Select2.init(`#answer-form-${data.question.id}-research-output-${data.research_output.id}`);
    }).fail((error) => {
      failCallback(error, target);
    });
  });
});
