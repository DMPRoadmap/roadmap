/* eslint-env browser */ // This allows us to reference 'window' below
$(() => {
  // Rotate trhough the news items every 8 seconds
  const news = JSON.parse(`${$('#home-news-array').val().replace(/\\"/g, '"').replace(/\\'/g, '\'')}`);
  const updateNews = (item) => {
    const text = $('#home-news-link');
    text.hide();
    text.html(`<a href="${news[item].link}" target="_blank">${news[item].title}</a>`);
    text.fadeIn(100);
  };
  const startNewsTimer = (item) => {
    setTimeout(() => {
      updateNews(item);
      startNewsTimer((item >= news.length - 1) ? 0 : item + 1);
    }, 8000);
  };
  updateNews(0);
  startNewsTimer(1);

  $('a#show-sign-in-form').click(() => {
    $('#access-control-tabs a[data-target="#sign-in-form"]').tab('show');
  });
  $('a#show-create-account-form').click(() => {
    $('#access-control-tabs a[data-target="#create-account-form"]').tab('show');
  });

  $('#get-started-options a').click((e) => {
    $(e.target).closest('.modal').modal('hide');
  });
});
