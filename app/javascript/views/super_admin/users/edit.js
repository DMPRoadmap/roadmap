import { initOrgSelection, validateOrgSelection } from '../../shared/my_org';

$(() => {
  const options = { selector: '#super_admin_user_edit' };
  initOrgSelection(options);

  $('#super_admin_user_edit').on('submit', (e) => {
    // Additional validation to force the user to choose an org or type something for other
    if (!validateOrgSelection(options)) {
      e.preventDefault();
    }
  });

  $('#merge_form').on('ajax:success', (e, data) => {
    // replace the search form with the merge form
    $('#merge_form_container').html(data.form);
  });
});
