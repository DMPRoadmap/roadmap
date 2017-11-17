$(() => {
  // Event delegation for paginable class so that any children a[data-remote="true"]
  // now or in future will be handled through this eventListener
  $('.paginable').on('ajax:success', 'a[data-remote="true"]', (e, data) => {
    $(e.target).closest('.paginable').html(data);
  });
});
