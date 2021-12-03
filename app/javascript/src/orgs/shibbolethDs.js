import getConstant from '../utils/constants';
import { initAutocomplete, scrubOrgSelectionParamsOnSubmit } from '../utils/autoComplete';

$(() => {
  $('#show_list').click((e) => {
    e.preventDefault();
    if ($('#full_list').is('.hidden')) {
      $('#full_list').removeClass('hidden').attr('aria-hidden', 'false');
      $(e.currentTarget).html(getConstant('SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST'));
    } else {
      $('#full_list').addClass('hidden').attr('aria-hidden', 'true');
      $(e.currentTarget).html(getConstant('SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST'));
    }
  });

  if ($('#shibboleth-ds-org-controls').length > 0) {
    initAutocomplete('#shibboleth-ds-org-controls .autocomplete');
    // Scrub out the large arrays of data used for the Org Selector JS so that they
    // are not a part of the form submissiomn
    scrubOrgSelectionParamsOnSubmit('#shibboleth_ds');
  }
});
