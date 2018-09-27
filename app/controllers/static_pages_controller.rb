# frozen_string_literal: true

class StaticPagesController < ApplicationController

# ------------------------------------
# START DMPTool customization
  def about_us
    dcc_news_feed_url = "http://www.dcc.ac.uk/news/dmponline-0/feed"
    @dcc_news_feed = Feedjira::Feed.fetch_and_parse dcc_news_feed_url
    respond_to do |format|
      format.rss { redirect_to dcc_news_feed_url }
      format.html { render 'static_pages/dmptool/about_us' }
    end
  end

  def contact_us
  end

  def roadmap
  end

  def privacy
  end

  def termsuse
    render 'static_pages/dmptool/termsuse'
  end

  def help
    render 'static_pages/dmptool/help'
  end

  def promote
    render 'static_pages/dmptool/promote'
  end

  def researchers
    render 'static_pages/dmptool/researchers'
  end

  def faq
    render 'static_pages/dmptool/faq'
  end

  def general_guidance
    render 'static_pages/dmptool/general_guidance'
  end

  def news_media
    render 'static_pages/dmptool/news_media'
  end
# END DMPTool customization
# ------------------------------------

end
