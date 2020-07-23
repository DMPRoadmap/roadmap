import { Tinymce } from '../../utils/tinymce.js.erb';
import { eachLinks } from '../../utils/links';
import { isObject, isString } from '../../utils/isType';
import { renderNotice, renderAlert } from '../../utils/notificationHelper';
import { scrollTo } from '../../utils/scrollTo';

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

  $('.edit_template').on('ajax:before', () => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#template-links').val(JSON.stringify(links));
    });
  });
  $('.edit_template').on('ajax:success', (e) => {
    const data = e.detail[0];
    if (isObject(data) && isString(data.msg)) {
      if (data.status === 200) {
        renderNotice(data.msg);
      } else {
        renderAlert(data.msg);
      }
      scrollTo('#notification-area');
    }
  });
  $('.edit_template').on('ajax:error', (e) => {
    const xhr = e.detail[2];
    const error = xhr.responseJSON;
    if (isObject(error) && isString(error)) {
      renderAlert(error.msg);
      scrollTo('#notification-area');
    }
  });
});
