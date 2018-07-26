$(() => {
  $('.heading-button').on('click', (e) => {
    $(e.currentTarget)
      .find('i.fa-plus, i.fa-minus')
      .toggleClass('fa-plus')
      .toggleClass('fa-minus');
  });
});
