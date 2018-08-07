import * as Validator from '../../../utils/validator';
import initMyOrgCombobox from '../../shared/my_org';

$(() => {
  initMyOrgCombobox({ selector: '#super_admin_user_edit' });
  Validator.enableValidations({ selector: '#super_admin_user_edit' });
});
