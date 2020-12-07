import {
  doneCallback,
  failCallback,
} from '../answers/edit';
// import TimeagoFactory from '../../utils/timeagoFactory';

$(() => {
  const showSavingMessage = jQuery => jQuery.parents('.question-form').find('[data-status="saving"]').show();
  const hideSavingMessage = jQuery => jQuery.parents('.question-form').find('[data-status="saving"]').hide();
  const showLoadingOverlay = jQuery => jQuery.find('.overlay').show();
  const hideLoadingOverlay = jQuery => jQuery.find('.overlay').hide();

  $('.question-content').on('shown.bs.collapse', (e) => {
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
      }).fail((error) => {
        failCallback(error, target);
      });
    }
  });
  $('.question-content').on('hide.bs.collapse', (e) => {
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
