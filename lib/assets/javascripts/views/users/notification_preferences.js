$(() => {
  $('#select_all').click(() => {
    $('.preferences').find('input[type="checkbox"]').prop('checked', true);
  });

  $('#deselect_all').click(() => {
    $('.preferences').find('input[type="checkbox"]').prop('checked', false);
  });

  $('#preferences_registration_form').on('submit', (e) => {
    const target = $(e.target);
    target.find('input[type="checkbox"]').each((i, el) => {
      const check = $(el);
      if (!check.prop('checked')) {
        target.append(`<input type="hidden" name="${check.attr('name')}" value="false">`);
      }
    });
  });
});

