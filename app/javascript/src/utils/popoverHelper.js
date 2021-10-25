import 'bootstrap-sass/popover';

$(() => {
  $('[data-toggle="popover"]').popover({
    animated: 'fade',
    placement: 'right',
  });
});
