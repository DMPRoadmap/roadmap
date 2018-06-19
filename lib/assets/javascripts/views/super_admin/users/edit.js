import ariatiseForm from '../../../utils/ariatiseForm';
import initMyOrgCombobox from '../../shared/my_org';

$(() => {
  ariatiseForm({ selector: '#super_admin_user_edit' });
  initMyOrgCombobox({ selector: '#super_admin_user_edit' });
});
