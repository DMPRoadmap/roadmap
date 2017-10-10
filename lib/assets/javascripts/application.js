// Not sure if this file is the best place for this.
import 'bootstrap-sass/assets/javascripts/bootstrap/tooltip';

import './views/answers/status';
import './views/contacts/new';
import './views/devise/invitations/edit';
import './views/devise/passwords/edit';
import './views/devise/passwords/new';
import './views/devise/registrations/edit';
import './views/notes/index';
import './views/orgs/shibboleth_ds';

import './views/phases/edit';
import './views/phases/show';
import './views/plans/download';
import './views/plans/edit_details';
import './views/plans/index';
import './views/plans/new';
import './views/plans/share';
import './views/orgs/admin_edit';

import './views/questions/new';
import './views/sections/index';
import './views/sections/new';
import './views/questions/index';
import './views/templates/show';
import './views/templates/edit';

// Not sure if this file is the best place for this. 
// All tables share the same class/id selectors so having it on one page makes it work everywhere
// All tooltips have the data-toggle="tooltip" attribute
import { collateTable, filteriseTable } from './utils/tableHelper';

$(() => {
  collateTable({ selector: 'table.tablesorter' });
  filteriseTable({ selector: '#filter' });

  // When using a tooltip on a tinymce textarea, add the HTML attributes for the tooltips to 
  // the parent `<div class="form-group">`. TODO: this does not work on focus though since tinymce
  // uses an iframe and we can't detect when the editor window gains focus. It only works on hover.
  //
  // If the content of the tooltip contains HTML, then add `data-html="true"` to the element
  $('[data-toggle="tooltip"]').tooltip({
    animated: 'fade',
    placement: 'right',
  });
});
