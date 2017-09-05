import ariatiseForm from '../../utils/ariatiseForm';

if ($) {
  $().ready(() => {
    // Invite Collaborators form on the Share page
    ariatiseForm({ selector: '#new_role' });
  });
}
