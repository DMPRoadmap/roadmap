$(document).on('click', '.structured-answer .actions .add-record', (e) => {
  const currentField = $(e.target.closest('.dynamic-field'));
  const clonedField = currentField.clone(true, true);

  clonedField.find('input').val(null);
  clonedField.find('.remove-record').show();

  currentField.after(clonedField);
});

$(document).on('click', '.structured-answer .actions .remove-record', (e) => {
  const currentField = $(e.target.closest('.dynamic-field'));
  currentField.remove();
});

// When the sub fragment modal opens
$('#sub-fragment-modal').on('show.bs.modal', (e) => {
  // Set the modal content (loads the form)
  const link = $(e.relatedTarget).data('open');
  const parent = $(e.relatedTarget).parent();
  $.ajax({
    url: link,
    method: 'get',
    success: (data) => {
      $('#sub-fragment-modal-body').html(data);
      $('#sub-fragment-modal-body').find('#parent_form_id').val(parent.attr('for'));
      $('#sub-fragment-modal-body').find('#parent_form_index').val(parent.attr('index'));
    },
    error: (err) => {
      console.log(err);
    },
  });
});

$(document).on('click', '.linked-fragments-list .actions .delete', (e) => {
  const target = $(e.target);
  // TODO : replace confirm()
  // eslint-disable-next-line
  const confirmed = confirm(target.data('confirm-message'));
  if (confirmed) {
    $.ajax({
      url: target.data('url'),
      method: 'delete',
    }).done((data) => {
      $(`.fragment-${data.fragment_id} .linked-fragments-list tbody`).html(data.html);
    });
  }
});
