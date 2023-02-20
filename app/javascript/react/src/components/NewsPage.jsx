import React from 'react';
import { get } from 'lodash';
import NewsItem from './NewsItem.jsx';
import { getNews } from '../../services/NewsServiceApi.js';

// eslint-disable-next-line react/prop-types, arrow-body-style
class HomepageNews extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isLoaded: false,
      news: [],
      error: null,
    };
  }

  componentDidMount() {
    getNews()
      .then(
        (result) => {
          const news = result.data.map((r) => ({
            id: r.id,
            title: r.title.rendered,
            link: r.link,
            date: new Date(r.date).toLocaleDateString('fr-FR'),
            thumbnail: get(r, ['_embedded', 'wp:featuredmedia', '0', 'media_details', 'sizes', 'medium_large']),
          }));
          this.setState({
            isLoaded: true,
            news,
          });
        },
        (error) => {
          this.setState({
            isLoaded: true,
            error,
          });
        },
      );
  }

  render() {
    let newsContent = 'Loading ...';
    if (this.state.isLoaded) {
      newsContent = (
        this.state.news.map((n) => <NewsItem key={n.id} news={n}/>)
      );
    }
    return (
      <div id='news-page'>
        {newsContent}
      </div>
    );
  }
}

export default HomepageNews;
