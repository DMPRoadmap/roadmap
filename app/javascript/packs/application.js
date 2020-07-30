// Rails setup
import 'jquery-ujs';
import 'jquery-accessible-autocomplete-list-aria/jquery-accessible-autocomplete-list-aria';
import 'bootstrap-select/js/bootstrap-select';

// Generic JS that is applicable across multiple pages
import '../utils/array';
import '../utils/charts';
import '../utils/autoComplete';
import '../utils/externalLink';
import '../utils/paginable';
import '../utils/panelHeading';
import '../utils/links';
import '../utils/outOfFocus';
import '../utils/tabHelper';
import '../utils/tooltipHelper';
import '../utils/popoverHelper';
import '../utils/requiredField';
import '../utils/tinymce.js.erb';
import '../utils/sectionUpdate';

// Page specific JS
import '../views/answers/edit';
import '../views/answers/conditions';
import '../views/answers/rda_metadata';
import '../views/contributors/form';
import '../views/devise/invitations/edit';
import '../views/devise/passwords/edit';
import '../views/devise/registrations/edit';
import '../views/guidances/new_edit';
import '../views/notes/index';
import '../views/org_admin/phases/new_edit';
import '../views/org_admin/phases/preview';
import '../views/org_admin/phases/show';
import '../views/org_admin/question_options/index';
import '../views/org_admin/questions/sharedEventHandlers';
import '../views/org_admin/sections/index';
import '../views/org_admin/templates/edit';
import '../views/org_admin/templates/index';
import '../views/org_admin/templates/new';
import '../views/orgs/admin_edit';

// ----------------------------------------
// START DMPTool customization
// ----------------------------------------
// import '../views/orgs/shibboleth_ds';
// ----------------------------------------
// END DMPTool customization
// ----------------------------------------

import '../views/plans/download';
import '../views/plans/edit_details';
import '../views/plans/index';
import '../views/plans/new';
import '../views/plans/share';
import '../views/roles/edit';
import '../views/shared/create_account_form';
import '../views/shared/sign_in_form';
import '../views/super_admin/api_clients/form';
import '../views/super_admin/themes/new_edit';
import '../views/super_admin/users/edit';
import '../views/usage/index';
import '../views/users/notification_preferences';
import '../views/users/admin_grant_permissions';
import '../views/super_admin/notifications/edit';
import '../views/public_templates/show';

// ----------------------------------------
// START DMPTool customization
// ----------------------------------------
import '../dmptool/views/home/index';
import '../dmptool/views/shared/org_branding';
import '../dmptool/views/shared/signin_create_form';
// ----------------------------------------
// END DMPTool customization
// ----------------------------------------
