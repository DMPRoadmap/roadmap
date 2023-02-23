import { define } from 'remount';
import FormRoot from './components/FormRoot.jsx';
import HomepageNews from './components/HomepageNewsPage';
import NewsPage from './components/NewsPage.jsx';

define({
  'dmp-homepage-news-page': HomepageNews,
  'dmp-news-page': NewsPage,
  'dmp-form-root': FormRoot,
});
