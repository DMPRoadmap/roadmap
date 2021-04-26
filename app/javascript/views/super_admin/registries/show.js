
$(() => {
  $('#registry-values').sortable({
    items: '.registry-value',
    handle: '.registry-value-actions .handle',
    update: () => {
      const updatedOrder = [];
      const registryId = $('#registry-values #registry-id').val();
      $('#registry-values .registry-value').each(function callback() {
        updatedOrder.push($(this).find('.registry-value-id').val());
      });
      $.ajax({
        url: '/super_admin/registries/sort_values',
        method: 'post',
        data: {
          id: registryId,
          updated_order: updatedOrder,
        },
      });
    },
  });
});
