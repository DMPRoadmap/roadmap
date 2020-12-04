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
        doneCallback(data, target);
      }).fail((error) => {
        failCallback(error, target);
      });
    }
  });
  $('.question-content').on('hide.bs.collapse', (e) => {
    const target = $(e.target);
    console.log(target.find('form'));
  });
});
