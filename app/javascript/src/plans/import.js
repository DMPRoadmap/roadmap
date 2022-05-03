import toggleSpinner from '../utils/spinner';

$(() => {
  $('body').on('click', '.plan-import', () => {
    toggleSpinner(true);
  });
  $('body').on('change', '#import-format input:radio[name="import[format]"]', (e) => {
    const $rdaMessage = $('.rda-message');
    if ($(e.target).val() === 'rda') {
      $rdaMessage.show();
    } else {
      $rdaMessage.hide();
    }
  });
});
