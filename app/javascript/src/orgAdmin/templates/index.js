import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../../utils/autoComplete';

$(() => {
  // Update the contents of the table when user clicks on a scope link
  $('.template-scope').on('ajax:success', 'a[data-remote="true"]', (e) => {
    const data = e.detail[0];
    $(e.target).closest('.template-scope').find('.paginable').html(data.html);
  });

  if ($('#super-admin-switch-org').length > 0) {
    initAutocomplete('#super-admin-switch-org .autocomplete');
    // Scrub out the large arrays of data used for the Org Selector JS so that they
    // are not a part of the form submissiomn
    scrubOrgSelectionParamsOnSubmit('#super-admin-switch-org');
  }
});
