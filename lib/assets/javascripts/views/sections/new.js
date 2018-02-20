$(() => {
  $('.section_new_cancel').on('click', (e) => {
    const sectionNew = $(e.target).closest('.section_new');
    sectionNew.hide();
    sectionNew.closest('.row').find('.section_new_link').show();
  });
});
