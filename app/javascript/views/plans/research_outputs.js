
$(() => {
  $('#research-outputs').sortable({
    items: '.research-output-element:not(.inactive)',
    handle: '.research-output-actions .handle',
    stop: () => {
      $('#research-outputs .research-output-element').each(function callback(index) {
        $(this).find('.research-output-order').val(index + 1);
      });
    },
  });

  // $('#add-research-output').click(() => {
  //   $.ajax({
  //     url: '/research_outputs/create_remote',
  //     method: 'get',
  //     success: (data) => {
  //       $('#research-outputs').html(data.html);
  //     },
  //     error: (err) => {
  //       console.log(err);
  //     },
  //   });
  // });
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
