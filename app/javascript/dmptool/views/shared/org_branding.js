// This is the branded Org sign in/create account page
$(() => {
  const orgControls = $('#create-account-org-controls');

  // We already know what org to use, so hide the selector and pre-populate
  // the field with the org id the user selected in the prior page
  if (orgControls.length > 0) {
    const orgId = orgControls.find('#new_user_org_id');

    if (orgId.length > 0) {
      const id = $('#default_org_id');
      const name = $('#default_org_name');

      if (id.length > 0 && name.length > 0) {
        if (id.val().length > 0 && name.val().length > 0) {
          orgId.val(JSON.stringify({ id: id.val(), name: name.val() }));
          orgControls.hide();
        }
      }
    }
  }
}); 
