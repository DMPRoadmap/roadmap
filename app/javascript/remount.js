import { define } from 'remount';
import HomepageNews from './dmp_opidor_react/src/components/news/HomepageNews.jsx';
import NewsPage from './dmp_opidor_react/src/components/news/NewsPage.jsx';

import GeneralInfoLayout from './dmp_opidor_react/src/components/GeneralInfo/GeneralInfoLayout.jsx';
import PlanCreationLayout from './dmp_opidor_react/src/components/PlanCreation/PlanCreationLayout.jsx';

define({
  'dmp-homepage-news-page': HomepageNews,
  'dmp-news-page': NewsPage,
  'dmp-general-info': GeneralInfoLayout,
  'dmp-plan-creation': PlanCreationLayout,
});
