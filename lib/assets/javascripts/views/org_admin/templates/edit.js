import { Tinymce } from '../../../utils/tinymce';
import { eachLinks } from '../../../utils/links';
import { isObject, isString } from '../../../utils/isType';
import { renderNotice, renderAlert } from '../../../utils/notificationHelper';
import { scrollTo } from '../../../utils/scrollTo';

$(() => {
  Tinymce.init({ selector: '.template' });
  $('.template_show_link').on('click', (e) => {
    e.preventDefault();
    $(e.target).closest('.template_edit').hide();
    $(e.target).closest('.tab-pane').find('.template_show').show();
  });
  $('.edit_template').on('submit', () => {
    const links = {};
    eachLinks((ctx, value) => {
      links[ctx] = value;
    }).done(() => {
      $('#template-links').val(JSON.stringify(links));
    });
  });
  $('.edit_template').on('ajax:success', (e, data) => {
    if (isObject(data) && isString(data.msg)) {
      renderNotice(data.msg);
      scrollTo('#notification-area');
    }
  });
  $('.edit_template').on('ajax:error', (e, xhr) => {
    const error = xhr.responseJSON;
    if (isObject(error) && isString(error)) {
      renderAlert(error.msg);
      scrollTo('#notification-area');
    }
  });
});
