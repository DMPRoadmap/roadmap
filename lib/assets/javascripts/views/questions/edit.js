import { Tinymce } from '../../utils/tinymce';
import ariatiseForm from '../../utils/ariatiseForm';
import onChangeQuestionFormat from './sharedEventHandlers';

$(() => {
  Tinymce.init({ selector: '.question' });
  ariatiseForm({ selector: '.question_form' });
  $('.edit_question_cancel').on('click', (e) => {
    e.preventDefault();
    const questionEdit = $(e.target).closest('.question_edit');
    questionEdit.hide();
    questionEdit.parent().find('.question_show').show();
  });
  $('[name="question[question_format_id]"]').on('change', onChangeQuestionFormat);
});
