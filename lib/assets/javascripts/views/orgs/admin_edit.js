// TODO: we need to be able to swap in the appropriate locale here
import 'number-to-text/converters/en-us';
import { enableValidations, validate } from '../../utils/validation';
import { Tinymce } from '../../utils/tinymce';
import { eachLinks } from '../../utils/links';

$(() => {
  const toggleFeedback = () => {
    if ($('#org_feedback_enabled_true').is(':checked')) {
      $('#feeback-email input, #feeback-email textarea').removeAttr('disabled');
    } else {
      $('#feeback-email input, #feeback-email textarea').attr('disabled', true);
    }
  };

  $('#edit_org_feedback_form input[type="radio"]').click(() => {
    toggleFeedback();
  });

  // Initialises tinymce for any target element with class tinymce_answer
  Tinymce.init({ selector: '#org_feedback_email_msg' });
  toggleFeedback();

  enableValidations($('#edit_org_profile_form'));
  $('#edit_org_profile_form').on('submit', (e) => {
    if (!validate(e.target)) {
      e.preventDefault();
    } else {
      const links = {};
      eachLinks((ctx, value) => {
        links[ctx] = value;
      }).done(() => {
        $('#org_links').val(JSON.stringify(links));
      });
    }
  });
});
