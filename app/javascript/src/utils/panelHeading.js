$(() => {
  $('body').on('click', '.heading-button', (e) => {
    $(e.currentTarget)
      .find('i.fa-plus, i.fa-minus')
      .toggleClass('fa-plus')
      .toggleClass('fa-minus');
  });
});
