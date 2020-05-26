import 'bootstrap-sass/assets/javascripts/bootstrap/popover';

$(() => {
  $('[data-toggle="popover"]').popover({
    animated: 'fade',
    placement: 'right',
  });
});
