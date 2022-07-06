
$(() => {
  const sso_toggle = $('#sign-in-bypass-sso');

  if (sso_toggle.length > 0){
    sso_toggle.on('click', (e) => {
      e.preventDefault();
      const form = sso_toggle.closest('form');
      form.attr('action', '/users/sign_in?bypass_sso=true');
      form.submit();
    });
  }
});
