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
      $(`.fragment-${data.fragment_id} .linked-fragments-list tbody`).html(data.html);
    });
  }
});

// $(document).on('click', 'a.load-defaults', (e) => {
//   const link = $(e.target);
//   const schemaFields = link.find('input[id^=madmp_fragment]');
//   schemaFields.each((field) => {
//     const f = $(field);
//     f.val(f.attr('default_value'));
//   });
//   e.preventDefault();
// });

$(document).on('click', 'a.load-defaults', (e) => {
  e.preventDefault();
  // eslint-disable-next-line no-console
  const link = $(e.target);
  const schemaFields = link.parent().find('input[id^=madmp_fragment]');
  for (let i = 0; i < schemaFields.length; i += 1) {
    const f = $(schemaFields[i]);
    f.val(f.attr('default_value'));
  }
});
