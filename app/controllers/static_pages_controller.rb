class StaticPagesController < ApplicationController

  def about_us
    dcc_news_feed_url = "https://opidor.fr/category/dmp-news/feed/"
		@dcc_news_feed = Feedjira::Feed.fetch_and_parse(dcc_news_feed_url)
		respond_to do |format|
			format.rss { redirect_to dcc_news_feed_url }
			format.html
end
  end

  def contact_us
  end

  def roadmap
    
  end

  def tutorials
    
  end
end