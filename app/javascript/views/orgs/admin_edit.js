// TODO: we need to be able to swap in the appropriate locale here
import 'number-to-text/converters/en-us';
import { isObject } from '../../utils/isType';
import { Tinymce } from '../../utils/tinymce.js.erb';
import { eachLinks } from '../../utils/links';

$(() => {
  const toggleFeedback = () => {
    const editor = Tinymce.findEditorById('org_feedback_email_msg');
    if (isObject(editor)) {
      if ($('#org_feedback_enabled_true').is(':checked')) {
        editor.setMode('code');
      } else {
        editor.setMode('readonly');
      }
    }
  };

  $('#edit_org_feedback_form input[type="radio"]').click(() => {
    toggleFeedback();
  });

  // Initialises tinymce for any target element with class tinymce_answer
  Tinymce.init({ selector: '#org_feedback_email_msg' });
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
});
