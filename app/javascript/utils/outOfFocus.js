$(() => {
  $('td').children('div.dropdown').each((i, el) => {
    const td = $(el).parent();
    const toggleBtn = $(td.find('div.dropdown').find('.dropdown-toggle'));
    td.focusout(() => {
      toggleBtn.dropdown('toggle');
    });
  });
});
