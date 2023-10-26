$(() => {
  $('#research-outputs').sortable({
    items: '.research-output-element:not(.inactive)',
    handle: '.research-output-actions .handle',
    update: () => {
      const updatedOrder = [];
      const planId = $('#research-outputs #plan_id').val();
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
  $('#research-outputs').on('ajax:success', (e) => {
    const data = e.detail[0];
    $('#research-outputs-list').html(data.html);
  });

  $('#research-outputs').on('click', '.research-output-actions .edit', (e) => {
    const form = $(e.target).parents('form');
    form.find('.research-output-fields .edit').fadeIn().css('display', 'flex');
    form.find('.research-output-fields .cancel').show();
    form.find('.research-output-fields  .readonly').hide();
  });
  $('#research-outputs').on('click', '.research-output-fields .cancel', (e) => {
    const form = $(e.target).parents('form');
    form.find('.research-output-fields .readonly').show();
    form.find('.research-output-fields  .edit').hide();
    form.find('.research-output-fields  .cancel').hide();
  });
  $('#research-outputs').on('click', '.research-output-fields .research-output-uuid .copy', (e) => {
    const uuidField = $(e.target).parents('.research-output-uuid');
    const uuid = uuidField.find('input').val();
    uuidField.find('.action.copy').removeClass('fa-copy').addClass('fa-check');
    navigator.clipboard.writeText(uuid);
  });
});
