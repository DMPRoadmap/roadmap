import {
  doneCallback,
  failCallback,
} from '../answers/edit';
import { Tinymce } from '../../utils/tinymce.js.erb';
import { Select2 } from '../../utils/select2';
// import TimeagoFactory from '../../utils/timeagoFactory';

$(() => {
  const showSavingMessage = jQuery => jQuery.parents('.question-form').find('[data-status="saving"]').show();
  const hideSavingMessage = jQuery => jQuery.parents('.question-form').find('[data-status="saving"]').hide();
  const showLoadingOverlay = jQuery => jQuery.find('.overlay').show();
  const hideLoadingOverlay = jQuery => jQuery.find('.overlay').hide();
  const toolbar = 'bold italic | bullist numlist | link | table';

  $('.panel-collapse').on('shown.bs.collapse', (e) => {
    const target = $(e.target);
    if (!target.hasClass('fragment-content')) {
      return;
    }
    const form = target.find('form');

    if (form.hasClass('new-fragment')) {
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
      }).fail((error) => {
        failCallback(error, target);
      });
    } else {
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
        doneCallback(data, target);
        Tinymce.init({
          selector: `#research_output_${data.research_output.id}_section_${data.section.id} .note`,
          toolbar,
        });
        Select2.init(`#answer-form-${data.question.id}-research-output-${data.research_output.id}`);
      }).fail((error) => {
        failCallback(error, target);
      });
    }
  });
  $('.panel-collapse').on('hide.bs.collapse', (e) => {
    const target = $(e.target);
    if (!target.hasClass('fragment-content')) {
      return;
    }
    const fragmentId = target.find('.fragment-id').val();
    target.find('.answer-form').html(`<input type="hidden" name="fragment-id" id="fragment-id" value="${fragmentId}" class="fragment-id">`);
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
      Select2.init(`#answer-form-${data.question.id}-research-output-${data.research_output.id}`);
    }).fail((error) => {
      failCallback(error, target);
    });
  });
});
