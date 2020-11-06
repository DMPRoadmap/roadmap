<<<<<<< HEAD
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
import '../views/orgs/shibboleth_ds';
import '../views/plans/download';
import '../views/plans/edit_details';
import '../views/plans/index';
import '../views/plans/new';
import '../views/plans/share';
import '../views/roles/edit';
import '../views/shared/create_account_form';
import '../views/shared/sign_in_form';
import '../views/super_admin/apiClients/form';
import '../views/super_admin/themes/new_edit';
import '../views/super_admin/users/edit';
import '../views/usage/index';
import '../views/users/notification_preferences';
import '../views/users/admin_grant_permissions';
import '../views/super_admin/notifications/edit';
import '../views/public_templates/show';
=======
/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import 'core-js/stable';
import 'regenerator-runtime/runtime';

// Pull in Bootstrap JS functionality
import 'bootstrap';
import 'bootstrap-3-typeahead';
import 'bootstrap-select';

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Utilities
import '../src/utils/accordion';
import '../src/utils/autoComplete';
import '../src/utils/externalLink';
import '../src/utils/outOfFocus';
import '../src/utils/paginable';
import '../src/utils/panelHeading';
import '../src/utils/popoverHelper';
import '../src/utils/requiredField';
import '../src/utils/tabHelper';
import '../src/utils/tooltipHelper';

// View specific JS
import '../src/answers/conditions';
import '../src/answers/edit';
import '../src/answers/rdaMetadata';
import '../src/contributors/form';
import '../src/devise/invitations/edit';
import '../src/devise/passwords/edit';
import '../src/devise/registrations/edit';
import '../src/devise/registrations/new';
import '../src/guidances/newEdit';
import '../src/notes/index';
import '../src/orgs/adminEdit';
import '../src/orgs/shibbolethDs';
import '../src/plans/download';
import '../src/plans/editDetails';
import '../src/plans/index.js.erb';
import '../src/plans/new';
import '../src/plans/share';
import '../src/publicTemplates/show';
import '../src/roles/edit';
import '../src/shared/createAccountForm';
import '../src/shared/signInForm';
import '../src/usage/index';
import '../src/users/adminGrantPermissions';
import '../src/users/notificationPreferences';

// OrgAdmin view specific JS
import '../src/orgAdmin/conditions/updateConditions';
import '../src/orgAdmin/phases/newEdit';
import '../src/orgAdmin/phases/preview';
import '../src/orgAdmin/phases/show';
import '../src/orgAdmin/questionOptions/index';
import '../src/orgAdmin/questions/sharedEventHandlers';
import '../src/orgAdmin/sections/index';
import '../src/orgAdmin/templates/edit';
import '../src/orgAdmin/templates/index';
import '../src/orgAdmin/templates/new';

// SuperAdmin view specific JS
import '../src/superAdmin/notifications/edit';
import '../src/superAdmin/themes/newEdit';
import '../src/superAdmin/users/edit';

// Since we're using Webpacker to manage JS we need to startup Rails' Unobtrusive JS
// and Turbolinks. ActiveStorage and ActionCable would also need to be in here
// if we decide to implement either before Rails 6
require('@rails/ujs').start();

// TODO: Disabled turbolinks for the time being because our custom JS is not
//       properly setup to work with it. We should review the docs:
//       https://github.com/turbolinks/turbolinks
// require('turbolinks').start();
// require("@rails/activestorage").start()
// require("@rails/actioncable").start()
>>>>>>> master
