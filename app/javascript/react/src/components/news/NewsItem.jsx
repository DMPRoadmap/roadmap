import React from 'react';
import PropTypes from 'prop-types';

const NewsItem = ({ news }) => {
  console.log(news);
  return (
    <article className='news-item'>
      <a className='news-link' href={news.link} target='_blank' rel="noreferrer">
        <img className='news-img' src={news.thumbnail.source_url} />
        <h3 className='news-title' dangerouslySetInnerHTML={{ __html: news.title }}></h3>
      </a>
      <span className='news-date'>{news.date}</span>
    </article>
  );
};

NewsItem.propTypes = {
  news: PropTypes.shape({
    title: PropTypes.string,
    date: PropTypes.string,
    link: PropTypes.string,
    thumbnail: PropTypes.object,
  }),
};

export default NewsItem;
