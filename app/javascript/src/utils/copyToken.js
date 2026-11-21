const initCopyToken = () => {
  document.addEventListener('click', function (e) {
    const button = e.target.closest('#copy-token-btn');
    if (!button) return;

    e.preventDefault();

    // Prevent spam clicking
    if (button.disabled) return;

    const tokenInput = document.getElementById('api-token-val');
    if (!tokenInput) return;

    const originalHTML = button.innerHTML;

    // Disable immediately
    button.disabled = true;

    navigator.clipboard.writeText(tokenInput.value).then(() => {
      // Replace button contents with check icon
      button.innerHTML = '<i class="fa fa-circle-check" aria-hidden="true"></i>';

      // Restore after 2s
      setTimeout(() => {
        button.innerHTML = originalHTML;
        button.disabled = false;
      }, 2000);
    }).catch(() => {
      button.disabled = false;
      alert('Failed to copy token');
    });
  });
};

initCopyToken();
