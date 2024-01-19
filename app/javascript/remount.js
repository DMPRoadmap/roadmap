import { define } from 'remount';
import NewsPageLayout from './dmp_opidor_react/src/components/news/NewsPageLayout.jsx';

import Comment from './dmp_opidor_react/src/components/Shared/Comment.jsx';
import ContributorsTabLayout from './dmp_opidor_react/src/components/ContributorsTab/ContributorsTabLayout.jsx';
import GeneralInfoLayout from './dmp_opidor_react/src/components/GeneralInfo/GeneralInfoLayout.jsx';
import PlanCreationLayout from './dmp_opidor_react/src/components/PlanCreation/PlanCreationLayout.jsx';
import WritePlanLayout from './dmp_opidor_react/src/components/WritePlan/WritePlanLayout.jsx';

define({
  'dmp-news-page': NewsPageLayout,
  'dmp-general-info': GeneralInfoLayout,
  'dmp-plan-creation': PlanCreationLayout,
  'dmp-write-plan': WritePlanLayout,
  'dmp-comment': Comment,
  'dmp-contributors-tab': ContributorsTabLayout,
});
