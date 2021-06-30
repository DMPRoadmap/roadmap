// Will display a spinner at the start of any UJS/Ajax call and then hide it after the
// controller responds.

const toggleSpinner = () => {
  const spinnerBlock = $('.spinner-border');

  if (spinnerBlock.length > 0) {
    if (spinnerBlock.hasClass('hidden')) {
      spinnerBlock.removeClass('hidden');
    } else {
      spinnerBlock.addClass('hidden');
    }
  }
};

$(() => {
  // Setup the spinner to show/hide during any UJS based Ajax calls
  // All other Jquery Ajax calls must import the toggleSpinner function above
  // and invoke it on send and complete.
  $('body').on('ajax:send', toggleSpinner);
  $('body').on('ajax:success', toggleSpinner);
  $('body').on('ajax:error', toggleSpinner);
});

export default toggleSpinner;
