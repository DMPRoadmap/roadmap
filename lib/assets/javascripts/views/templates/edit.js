import { Tinymce } from '../../utils/tinymce';
import { eachLinks } from '../../utils/links';

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
});
