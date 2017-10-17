import * as notifier from '../../utils/notificationHelper';
import ariatiseForm from '../../utils/ariatiseForm';

$(() => {
  // Invite Collaborators form on the Share page
  ariatiseForm({ selector: '#new_role' });

  const xhrRequest = (el) => {
    const form = $(el).closest('form');

    $.ajax({
      method: $(form).attr('method'),
      url: $(form).attr('action'),
      data: $(form).serializeArray(),
      dataType: 'json',
    }).done((data) => {
      if (data.code === 1 && data.msg && data.msg !== '') {
        notifier.renderNotice(data.msg);
      } else {
        notifier.renderAlert(data.msg);
      }
    }, () => {
      // TODO adequate error handling for network error 
    });
  };

  $('#set_visibility [name="plan[visibility]"]').click((e) => {
    xhrRequest(e.currentTarget);
  });

  $('.change_plan_role select').change((e) => {
    xhrRequest(e.currentTarget);
  });
});
