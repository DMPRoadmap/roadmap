import { Tinymce } from '../../../utils/tinymce';
import { enableValidations, validate } from '../../../utils/validation';
import { eachLinks } from '../../../utils/links';

$(() => {
  Tinymce.init({
    selector: '.template',
    init_instance_callback(editor) {
      // When the text editor changes to blank, set the corresponding destroy
      // field to true (if present).
      editor.on('Change', () => {
        const $texteditor = $(editor.targetElm);
        const $fieldset = $texteditor.parents('fieldset');
        const $hiddenField = $fieldset.find('input[type=hidden][id$="_destroy"]');
        $hiddenField.val(editor.getContent() === '');
      });
    },
  });
  enableValidations($('.new_template'));
  $('.new_template').on('submit', (e) => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#template-links').val(JSON.stringify(links));
    });
    if (!validate(e.target)) {
      e.preventDefault();
    }
  });
});
