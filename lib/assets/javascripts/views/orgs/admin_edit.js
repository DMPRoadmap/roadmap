// TODO: we need to be able to swap in the appropriate locale here
import 'number-to-text/converters/en-us';
import * as Validator from '../../utils/validator';
import { isString } from '../../utils/isType';
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
  Validator.enableValidations('#edit_org_profile_form .form-group:not(.link-input)');
  Validator.enableValidations('#edit_org_feedback_form .form-group');

  // Only enable validations on the links section if it has values initially
  $('.link').each((idx, el) => {
    // TODO: Move this to the utils/links.js
    const link = $(el).find('input[name="link_link"]');
    const text = $(el).find('input[name="link_text"]');
    if (isString(link.val()) && isString(text.val())) {
      // Validations are enabled if non-empty value is found
      if (link.val().length > 0 || text.val().length > 0) {
        Validator.enableValidation(link);
        Validator.enableValidation(text);
      }
    }
  });

  // update the hidden org_type field based on the checkboxes selected
  const calculateOrgType = () => {
    let orgType = 0;
    $('input.org_types:checked').each((i, el) => {
      orgType += parseInt($(el).val(), 10);
    });
    $('#org_org_type').val((orgType === 0 ? '' : orgType.toString()));
  };
  $('input.org_types').on('click', calculateOrgType);

  $('#edit_org_profile_form').on('submit', () => {
    // Collect links
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#org_links').val(JSON.stringify(links));
    });

    // if (!validate(e.target)) {
    //   e.preventDefault();
    // }
  });
});
