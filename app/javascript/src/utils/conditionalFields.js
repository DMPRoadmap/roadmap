// Logic to hide/dsiplay a set of fields based on whether or not a related checkbox is clicked
//
// Expecting the checkbox and the corresponding fields to be wrapped in
// a <conditional></conditional> element
//
// For example see: app/views/plans/_edit_details.html.erb
//                  app/javascript/src/plans/editDetails.js
//
import { Tinymce } from './tinymce.js.erb';

// Expecting `context` to be the field that triggers the hide/show of the corresponding fields
export default function toggleConditionalFields(context, showThem) {
  const container = $(context).closest('conditional');

  if (container.length > 0) {
    if (showThem === true) {
      container.find('.toggleable-field').show();

      // Resize any TinyMCE editors
      container.find('.toggleable-field').find('.tinymce').each((_idx, el) => {
        const tinymceEditor = Tinymce.findEditorById($(el).attr('id'));
        if (tinymceEditor) {
          $(tinymceEditor.iframeElement).height(tinymceEditor.settings.autoresize_min_height);
        }
      });
    } else {
      // Clear the contents of any textarea select boxes or input fields
      container.find('.toggleable-field').find('input, textarea, select').val('').change();

      // TODO: clear check boxes and radio buttons as needed

      // Clear the contents of any TinyMCE editors
      container.find('.toggleable-field').find('.tinymce').each((_idx, el) => {
        const tinymceEditor = Tinymce.findEditorById($(el).attr('id'));
        if (tinymceEditor) {
          tinymceEditor.setContent('');
        }
      });

      container.find('.toggleable-field').hide();
    }
  }
}
