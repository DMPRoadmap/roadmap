import toggleSpinner from '../utils/spinner';

$(() => {
  $('body').on('click', '.plan-import', () => {
    toggleSpinner(true);
  });
});
