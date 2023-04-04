import Swal from 'sweetalert2';

const ajaxCallCodebase = (target) => {
  const messageZone = target.parent().find('.message-zone');
  const overlay = target.parents('.fragment-content').find('.overlay');
  const url = target.data('url');
  $.ajax({
    url,
    method: 'get',
    beforeSend: () => {
      target.hide();
      overlay.show();
    },
    complete: () => {
      overlay.hide();
    },
  }).done((data) => {
    target.hide();
    if (data.needs_reload) {
      target.parents('.fragment-content').trigger('reload.form');
    } else {
      messageZone.addClass('valid');
      messageZone.html(data.message);
      messageZone.show();
    }
  }).fail((response) => {
    messageZone.html(response.responseJSON.error);
    messageZone.addClass('invalid');
    messageZone.show();
    target.show();
  });
};

$(() => {
  $(document).on('click', '.run-zone .run-button', (e) => {
    const target = $(e.target);
    if (target.hasClass('notifyer')) {
      const confirmMessage = target.data('confirm-message');
      Swal.fire({
        text: confirmMessage,
        showDenyButton: true,
        width: 500,
      }).then((result) => {
        if (result.isConfirmed) {
          ajaxCallCodebase(target);
        }
      });
    } else {
      ajaxCallCodebase(target);
    }
  });
});
