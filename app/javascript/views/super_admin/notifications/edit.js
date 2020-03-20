<<<<<<< HEAD
import { Tinymce } from '../../../utils/tinymce';
// add the info on selecting the check from notification suitable
=======
import { Tinymce } from '../../../utils/tinymce.js.erb';

//add the info on selecting the check from notification suitable
>>>>>>> 8cebbdfe52128dbb2af7c3e1f7f1407be62795c4
import { paginableSelector } from '../../../utils/paginable';
import * as notifier from '../../../utils/notificationHelper';


$(() => {
  Tinymce.init({ selector: '.notification-text', forced_root_block: '' });


  $(paginableSelector).on('click, change', '.set_active_notification input[type="checkbox"]', (e) => {
    const form = $(e.target).closest('form');
    form.submit();
  });


  $(paginableSelector).on('ajax:success', '.set_active_notification', (e, data) => {
    // const form = $(e.target);
    if (data.code === 1 && data.msg && data.msg !== '') {
      notifier.renderNotice(data.msg);
    } else {
      notifier.renderAlert(data.msg);
    }
    /* remove or display the div
    if (form.find('input[type="checkbox"]').is(':checked')) {
      form.parent().siblings('.plan-visibility').html(getConstant('PLAN_VISIBILITY_WHEN_TEST'))
        .attr('title', '');
     } else {
       form.parent().siblings('.plan-visibility').html(getConstant('PLAN_VISIBILITY_WHEN_NOT_TEST'))
        .attr('title', getConstant('PLAN_VISIBILITY_WHEN_NOT_TEST_TOOLTIP'));
    } */
  });
});
