$(() => {
  const createAccountForm = document.getElementById('create_account_form');

  if (!createAccountForm) {
    return;
  }

  const emailField = createAccountForm.querySelector('input[type="email"]');
  const orgSelect = createAccountForm.querySelector('select[name*="org"]');

  if (!emailField || !orgSelect) {
    return;
  }

  let currentDomain = '';
  let debounceTimer = null;

  // Handle email input changes
  emailField.addEventListener('input', function() {
    const email = this.value;

    if (email && email.includes('@')) {
      const domain = email.split('@')[1];

      // Only fetch if domain has changed
      if (domain && domain !== currentDomain) {
        currentDomain = domain;

        // Clear previous timer
        if (debounceTimer) {
          clearTimeout(debounceTimer);
        }

        // Debounce API calls to avoid too many requests
        debounceTimer = setTimeout(() => {
          fetchOrganizations(domain);
        }, 500);
      }
    } else {
      // Clear organizations if email is invalid
      currentDomain = '';
      resetOrgSelect();
    }
  });

  function fetchOrganizations(domain) {
    fetch(`/api/get-orgs-by-domain?domain=${encodeURIComponent(domain)}`)
      .then(response => response.json())
      .then(data => {
        populateOrgSelect(data);
      })
      .catch(error => {
        console.error('Error fetching organizations:', error);
        resetOrgSelect();
      });
  }

  function populateOrgSelect(orgs) {
    // Clear existing options
    orgSelect.innerHTML = '';

    // Add prompt option
    const promptOption = document.createElement('option');
    promptOption.value = '';
    promptOption.textContent = 'Select an organisation';
    orgSelect.appendChild(promptOption);

    // Add organization options
    orgs.forEach(function(org) {
      const option = document.createElement('option');
      option.value = org.id || org.ror_id;
      option.textContent = org.org_name;
      orgSelect.appendChild(option);
    });
  }

  function resetOrgSelect() {
    orgSelect.innerHTML = '<option value="">Select an organisation</option>';
  }
});

