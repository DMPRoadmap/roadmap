<<<<<<< HEAD:app/javascript/src/orgAdmin/templates/new.js
import { Tinymce } from '../../utils/tinymce.js.erb';
import { eachLinks } from '../../utils/links';
=======
import { Tinymce } from '../utils/tinymce.js.erb';
import { eachLinks } from '../utils/links';
>>>>>>> rails5:app/javascript/src/views/orgAdmin/templates/new.js

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
  $('.new_template').on('submit', () => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#template-links').val(JSON.stringify(links));
    });
  });
});
