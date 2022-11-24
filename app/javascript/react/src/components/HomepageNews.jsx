import React from 'react';

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
    fetch('https://opidor.fr/wp-json/wp/v2/posts?per_page=3&categories=5&_embed')
      .then((res) => res.json())
      .then(
        (result) => {
          this.setState({
            isLoaded: true,
            news: result,
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
    return <div>{JSON.stringify(this.state)}</div>;
  }
}

export default HomepageNews;
