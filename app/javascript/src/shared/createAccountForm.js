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

  let currentEmail = '';
  let debounceTimer = null;

  // Handle email input changes
  emailField.addEventListener('input', function () {
    const email = this.value;

    if (email && email.includes('@')) {
      if (email !== currentEmail) {
        currentEmail = email;

        // Clear previous timer
        if (debounceTimer) {
          clearTimeout(debounceTimer);
        }

        // Debounce API calls to avoid too many requests
        debounceTimer = setTimeout(() => {
          fetchOrganizations(email);
        }, 500);
      }
    } else {
      // Clear organizations if email is invalid
      currentEmail = '';
      resetOrgSelect();
    }
  });

  function fetchOrganizations(email) {
    // fetch(`/api/orgs-by-domain?email=${encodeURIComponent(email)}`)
    //   .then(response => response.json())
    //   .then(data => {
    //     populateOrgSelect(data);
    //   })
    //   .catch(error => {
    //     console.error('Error fetching organizations:', error);
    //     resetOrgSelect();
    //   });
    // Prepare header and body information for a POST request
    // Retrieve CSRF token stored in <meta> tag
    const csrftoken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    const requestOptions = {
        method: 'POST',
        headers: { 
            'Content-Type': 'application/json',
            // Add X-CSRF-Token header for protection against CRSF attacks.
            'X-CSRF-Token': csrftoken,
        },
        body: JSON.stringify({ email })
    };

    // Use Fetch API with POST configuration included in requestOptions
    fetch('/orgs-by-domain', requestOptions)
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

    if (orgs.length > 1) {
      // Add prompt option
      const promptOption = document.createElement('option');
      promptOption.value = '';
      promptOption.textContent = 'Select an organisation';
      orgSelect.appendChild(promptOption);
    }

    // Add organization options
    orgs.forEach(function (org) {
      const option = document.createElement('option');
      option.value = org.id || org.ror_id;
      option.textContent = org.org_name;
      orgSelect.appendChild(option);
    });
    // Only select option if only one
    if (orgs.length === 1) {
      orgSelect.selectedIndex = 0;
    }
  }

  function resetOrgSelect() {
    orgSelect.innerHTML = '';
  }
});

