import ariatiseForm from '../../utils/ariatiseForm';
import initMyOrgCombobox from '../shared/my_org';

$(() => {
  initMyOrgCombobox({ selector: '#create-account-form' });
  ariatiseForm({ selector: '#create-account-form' });
});
