// TODO: we need to be able to swap in the appropriate locale here
import 'number-to-text/converters/en-us';
import { isObject } from '../utils/isType';
import { eachLinks } from '../utils/links';

$(() => {
  const toggleFeedback = () => {
    const editor = Tinymce.findEditorById('org_feedback_msg');
    if (isObject(editor)) {
      if ($('#org_feedback_enabled_true').is(':checked')) {
        editor.mode.set('design');
      } else {
        editor.mode.set('readonly');
      }
    }
  };

  $('#edit_org_feedback_form input[type="radio"]').click(() => {
    toggleFeedback();
  });

  // Initialises tinymce for any target element with class tinymce_answer
  Tinymce.init({ selector: '#org_feedback_msg' });
  toggleFeedback();

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
  });

  $('.links [data-toggle="tooltip"]').on('click', (e) => {
    e.preventDefault();
    $(e.target).parent('a').tooltip('toggle');
  });

  Tinymce.init({ selector: '#org_api_create_plan_email_body' });

  // JS to update the email preview as the user edits the email body field
  const emailBodyControl = Tinymce.findEditorById('org_api_create_plan_email_body');
  const emailPreview = $('.replaceable-api-email-content');

  // Add handlers to the TinyMCE editor so that changes update the preview section
  if (emailBodyControl && emailPreview) {
    emailBodyControl.on('keyup', (e) => {
      emailPreview.html($(e.target).html());
    });
  }
});
