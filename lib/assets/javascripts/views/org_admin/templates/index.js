$(() => {
  // Update the contents of the table when user clicks on a scope link
  $('.template-scope').on('ajax:success', 'a[data-remote="true"]', (e, data) => {
    $(e.target).closest('.template-scope').find('.paginable').html(data);
  });
});
