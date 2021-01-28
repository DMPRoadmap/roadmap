$(document).on('click', '.madmp-fragment .actions .add-record', (e) => {
  const currentField = $(e.target.closest('.dynamic-field'));
  const clonedField = currentField.clone(true, true);

  clonedField.find('input').val(null);
  clonedField.find('.remove-record').show();

  currentField.after(clonedField);
});

$(document).on('click', '.madmp-fragment .actions .remove-record', (e) => {
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
      $(`table.list-${data.query_id} tbody`).html(data.html);
    });
  }
});

/*
 * Changes the url of the "View" link according to the selected value in the fragment select
*/
$(document).on('change', '.linked-fragments-select', (e) => {
  const value = e.target.value;
  const viewLink = $(e.target).parent().find('a');
  viewLink.attr('href', viewLink.attr('href').replace(/fragment_id=([^&]+)/, `fragment_id=${value}`));
});

$(document).on('change', '.schema_picker', (e) => {
  const target = $(e.target);
  const form = target.parents('.question').find('.form-answer');
  form.find('.schema_id').val(target.val());
  form.trigger('submit');
});
