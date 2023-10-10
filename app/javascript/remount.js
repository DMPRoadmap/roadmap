import { define } from 'remount';
import HomepageNews from './dmp_opidor_react/src/components/news/HomepageNews.jsx';
import NewsPage from './dmp_opidor_react/src/components/news/NewsPage.jsx';

import GeneralInfoLayout from './dmp_opidor_react/src/components/GeneralInfo/GeneralInfoLayout.jsx';
import PlanCreationLayout from './dmp_opidor_react/src/components/PlanCreation/PlanCreationLayout.jsx';
import WritePlanLayout from './dmp_opidor_react/src/components/WritePlan/WritePlanLayout.jsx';
import Comment from './dmp_opidor_react/src/components/Shared/Comment.jsx';

define({
  'dmp-homepage-news-page': HomepageNews,
  'dmp-news-page': NewsPage,
  'dmp-general-info': GeneralInfoLayout,
  'dmp-plan-creation': PlanCreationLayout,
  'dmp-write-plan': WritePlanLayout,
  'dmp-comment': Comment,
});
