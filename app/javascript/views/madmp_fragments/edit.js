import {
  doneCallback,
  failCallback,
} from '../answers/edit';
import { Tinymce } from '../../utils/tinymce.js.erb';
// import TimeagoFactory from '../../utils/timeagoFactory';

$(() => {
  const showSavingMessage = jQuery => jQuery.parents('.question-form').find('[data-status="saving"]').show();
  const hideSavingMessage = jQuery => jQuery.parents('.question-form').find('[data-status="saving"]').hide();
  const showLoadingOverlay = jQuery => jQuery.find('.overlay').show();
  const hideLoadingOverlay = jQuery => jQuery.find('.overlay').hide();
  const toolbar = 'bold italic | bullist numlist | link | table';

  $('.fragment-content').on('shown.bs.collapse', (e) => {
    const target = $(e.target);
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
      }).fail((error) => {
        failCallback(error, target);
      });
    }
  });
  $('.fragment-content').on('hide.bs.collapse', (e) => {
    const target = $(e.target);
    const fragmentId = target.find('.fragment-id').val();
    target.find('.answer-form').html(`<input type="hidden" name="fragment-id" id="fragment-id" value="${fragmentId}" class="fragment-id">`);
  });

  $('body').on('click', '.question .heading-button', (e) => {
    $(e.currentTarget)
      .find('i.fa-chevron-right, i.fa-chevron-down')
      .toggleClass('fa-chevron-right fa-chevron-down');
  });
});
