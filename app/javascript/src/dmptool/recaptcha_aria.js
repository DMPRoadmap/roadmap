// Google Recaptcha v3 adds 2 hidden TextArea fields to the page. These fields are hidden
// and only appear in the event of a failed security check. They do not include
// appropriate Aria markup for screen readers though, so adding them here.

$(() => {
  const gRecaptchaTextArea = $('#g-recaptcha-response');
  const gRecaptchaTextAreaTwo = $('#g-recaptcha-response-100000');

  const msg = 'Google Recaptcha response from security check.';

  if (gRecaptchaTextArea.length > 0) {
    gRecaptchaTextArea.attr('aria-label', msg);
  }
  if (gRecaptchaTextAreaTwo.length > 0){
    gRecaptchaTextAreaTwo.attr('aria-label', msg);
  }
});