import 'bootstrap/js/popover';

$(() => {
  $('[data-toggle="popover"]').popover({
    animated: 'fade',
    placement: 'right',
  });
});
