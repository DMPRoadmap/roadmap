import './views/answers/status';
import './views/contacts/new';
import './views/devise/invitations/edit';
import './views/devise/passwords/edit';
import './views/devise/passwords/new';
import './views/devise/registrations/edit';
import './views/notes/index';
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

// Not sure if this belongs here. All tables share the same class/id selectors 
// so having it on one page makes it work everywhere
import { collateTable, filteriseTable } from './utils/tableHelper';

$().ready(() => {
  collateTable({ selector: 'table.tablesorter' });
  filteriseTable({ selector: '#filter' });
});
