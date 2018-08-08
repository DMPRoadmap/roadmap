import ariatiseForm from '../../../utils/ariatiseForm';
import { initOrgSelection, validateOrgSelection } from '../../shared/my_org';

$(() => {
  const options = { selector: '#super_admin_user_edit' };
  ariatiseForm(options);
  initOrgSelection(options);

  $('#super_admin_user_edit').on('submit', (e) => {
    // Additional validation to force the user to choose an org or type something for other
    if (!validateOrgSelection(options)) {
      e.preventDefault();
    }
  });
});
