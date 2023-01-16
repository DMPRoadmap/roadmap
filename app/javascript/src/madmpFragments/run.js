$(() => {
  $(document).on('click', '.run-zone .run-button', (e) => {
    const target = $(e.target);
    const messageZone = target.parent().find('.message-zone');
    const overlay = target.parents('.fragment-content').find('.overlay');
    const url = target.data('url');
    const confirmMessage = target.data('confirm-message');
    let confirmed = true;

    if (target.hasClass('notifyer')) {
      // eslint-disable-next-line
      confirmed = confirm(confirmMessage);
    }

    if (confirmed) {
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
    }
  });
});
