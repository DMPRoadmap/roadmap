import getConstant from '../../../constants';
import { isObject } from '../../../utils/isType';
import initQuestionForm from './new_edit';
import initAnnotations from '../../annotations/form';

export default (context) => {
  if (isObject($(`#${context}`))) {
    // When the user is customizing the template the annotations appear on the
    // show.html.erb so initialize them
    initAnnotations(context);

    // When the user clicks the 'Edit' question button we swap out the contents of
    // current question container with the form
    // TODO: Not sure why, but use of the Rails `remote: true` does not work,
    //       so we use AJAX here. Would be better to sue the Rails `remote:true`
    $(`#${context} .edit-question`).on('click', (e) => {
      e.preventDefault();
      const target = $(e.target);
      const panel = $(`#${context}`);
      if (isObject(target) && isObject(panel)) {
        target.after(`&nbsp;&nbsp;<span class="loading">${getConstant('AJAX_LOADING')}</span>`);
        $.get(target.attr('href'))
          .done((data) => {
            panel.html(data);
            initQuestionForm(context);
          }).fail(() => {
            target.after(`<br><div class="pull-right alert alert-warning" role="alert">${getConstant('AJAX_UNABLE_TO_LOAD_TEMPLATE_SECTION_QUESTION')}</div>`);
          });
      }
    });
  }
};
