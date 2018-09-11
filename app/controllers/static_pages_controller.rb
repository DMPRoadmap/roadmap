# frozen_string_literal: true

class StaticPagesController < ApplicationController

# ------------------------------------
# START DMPTool customization
  include MarkdownHandler

  def about_us
    dcc_news_feed_url = "http://www.dcc.ac.uk/news/dmponline-0/feed"
    @dcc_news_feed = Feedjira::Feed.fetch_and_parse dcc_news_feed_url
    respond_to do |format|
      format.rss { redirect_to dcc_news_feed_url }
      format.html
    end

    render 'static_pages/dmptool/about_us'
  end
# END DMPTool customization
# ------------------------------------

  def contact_us
  end

  def roadmap
  end

  def privacy
    render 'static_pages/dmptool/privacy'
  end

  def termsuse
    render 'static_pages/dmptool/termsuse'
  end

  def help
    render 'static_pages/dmptool/help'
  end

end
