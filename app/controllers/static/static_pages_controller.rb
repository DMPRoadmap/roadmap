module Static
  class StaticPagesController < ApplicationController
    before_action :set_static_page, only: :show

    # GET /static/:name
    def show; end

    # Changed News feed
    def news_feed
      dcc_news_feed_url = "https://opidor.fr/category/dmp-news/feed/"
      @dcc_news_feed = Feedjira::Feed.fetch_and_parse dcc_news_feed_url
      respond_to do |format|
        format.rss { redirect_to dcc_news_feed_url }
        format.html
      end
    end
    
     # Added Tutorials Page
    def tutorials
  
    end

    private

    # Define static page to be rendered, 404 if needed
    def set_static_page
      @static_page = StaticPage.find_by(url: params[:name])
      render file: "#{Rails.root}/public/404", status: 404 unless @static_page
    end
  end
end