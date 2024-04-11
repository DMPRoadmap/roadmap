// Will display a spinner at the start of any UJS/Ajax call and then hide it after the
// controller responds.
const toggleSpinner = (visible) => {
  const spinnerBlock = $('.spinner-border');

  if (spinnerBlock.length > 0) {
    if (visible) {
      spinnerBlock.removeClass('d-none');
    } else {
      spinnerBlock.addClass('d-none');
    }
  }
};

$(() => {
  $('body').on('ajax:beforeSend', () => {
    toggleSpinner(true);
  });

  $('body').on('ajax:complete', () => {
    toggleSpinner(false);
  });

  $('body').on('ajax:error', () => {
    toggleSpinner(false);
  });

  $('body').on('ajax:stopped', () => {
    toggleSpinner(false);
  });

  $('body').on('ajax:success', () => {
    toggleSpinner(false);
  });

  toggleSpinner(false);
});

export default (visible) => toggleSpinner(visible);
