$(() => {
  $('.heading-button').on('click', (e) => {
    $(e.currentTarget).find('i.fa').toggleClass('fa-plus').toggleClass('fa-minus');
  });
});
