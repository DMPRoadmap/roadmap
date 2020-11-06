import 'bootstrap-sass/tooltip';

$(() => {
  // When using a tooltip on a tinymce textarea, add the HTML attributes for the tooltips to
  // the parent `<div class="form-group">`. TODO: this does not work on focus though since tinymce
  // uses an iframe and we can't detect when the editor window gains focus. It only works on hover.
  //
  // If the content of the tooltip contains HTML, then add `data-html="true"` to the element
  // Default behaviour for all tootips, when attribute data-placement not set
  $('[data-toggle="tooltip"]:not([data-placement])').tooltip({
    animated: 'fade',
    placement: 'right',
  });

  // Don't set placement property if data-placement present
  $('[data-toggle="tooltip"][data-placement]').tooltip({
    animated: 'fade',
  });
});
