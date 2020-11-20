$(() => {
  $('.section_new_link').on('click', (e) => {
    $(e.target).hide();
    $(e.target).closest('.row').find('.section_new').show();
  });
});
