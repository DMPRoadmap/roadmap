/* eslint-env browser */ // This allows us to reference 'window' below

$(() => {
  // If the URL contains a tab reference then show that tab
  const loc = window.location.hash;
  if (loc) {
    $(`ul.nav a[href="${loc}"]`).tab('show');
  }
  $('ul.nav a[data-toggle="tab"]').click((e) => {
    const target = $(e.target);
    $(target).tab('show');
    window.location.hash = $(target).attr('href');
  });
});
