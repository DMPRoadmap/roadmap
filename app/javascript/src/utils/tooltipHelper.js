import 'jquery-ui/tooltip';

$(() => {
  $('[data-toggle="tooltip"]').tooltip({
    position: { my: 'right+15', at: 'right center'},
  });
});
