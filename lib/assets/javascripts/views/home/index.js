/* eslint-env browser */ // This allows us to reference 'window' below

$(() => {
  $('a#show-sign-in-form').click(() => {
    $('#access-control-tabs a[data-target="#sign-in-form"]').tab('show');
  });
  $('a#show-create-account-form').click(() => {
    $('#access-control-tabs a[data-target="#create-account-form"]').tab('show');
  });
});
