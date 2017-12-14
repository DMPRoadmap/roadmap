/*
 * Confirmation modal expects the link/button that triggers the confirmation
 * to define the folowing attributes: 'confirm-href' and 'confirm-method'
 *
 * e.g. <a href="#" data-toggle="modal" data-target="#confirm-it"
 *         confirm-method="put" confirm-href="plans/1234">Remove</a>
 *
 * 'data-target' should match the name of the modal dialog.
 */
$(() => {
  $('.confirmation-modal').on('show.bs.modal', (e) => {
    $($(e.relatedTarget).attr('data-target')).find('.confirmation-continue')
      .attr('href', $(e.relatedTarget).attr('confirm-href'))
      .attr('data-method', $(e.relatedTarget).attr('confirm-method'));
  });
});
