
$(() => {
  $('#research-outputs').sortable({
    items: '.research-output-element:not(.inactive)',
    handle: '.research-output-actions .handle',
    update: () => {
      const updatedOrder = [];
      const planId = $('#research-outputs .plan-id').val()
      $('#research-outputs .research-output-element').each(function callback() {
        updatedOrder.push($(this).find('.research-output-id').val());
      });
      $.ajax({
        url: '/research_outputs/sort',
        method: 'post',
        data: {
          plan_id: planId,
          updated_order: updatedOrder,
        },
      });
    },
  });
  $('#research-outputs').on('ajax:success', (e, data) => {
    $('#research-outputs-list').html(data.html);
  });

  $('.research-output-type-select').change((e) => {
    const selectElement = $(e.target);
    const parentElement = selectElement.closest('.research-output-element');
    const otherTypeElement = parentElement.find('.research-output-other-type-label');
    if (selectElement.find('option:selected').data('other')) {
      otherTypeElement.find('input').prop('required', true);
      otherTypeElement.show();
    } else {
      otherTypeElement.find('input').prop('required', false);
      otherTypeElement.hide();
    }
  });
});
