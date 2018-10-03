import { togglisePasswords } from '../../utils/passwordHelper';
// START: DMPTOOL customization
// --------------------------------------------------
// import { initOrgSelection, validateOrgSelection } from './my_org';
import { initOrgSelection } from './my_org';
// --------------------------------------------------
// END: DMPTool customization

$(() => {
  // START: DMPTOOL customization
  // --------------------------------------------------
  // const options = { selector: '#create-account-form' };
  const options = { selector: '#create_account_form' };
  // --------------------------------------------------
  // END: DMPTool customization

  togglisePasswords(options);
  initOrgSelection(options);

  // START: DMPTOOL customization
  //        Disable JS validation for org selection
  // --------------------------------------------------
  // $('#create_account_form').on('submit', (e) => {
  //   // Additional validation to force the user to choose an org or type something for other
  //   if (!validateOrgSelection(options)) {
  //     e.preventDefault();
  //   }
  // });
  // --------------------------------------------------
  // END: DMPTool customization
});
