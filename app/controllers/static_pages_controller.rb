# frozen_string_literal: true

class StaticPagesController < ApplicationController

  prepend Dmpopidor::Controllers::StaticPages

  def about_us
    dcc_news_feed_url = "http://www.dcc.ac.uk/news/dmponline-0/feed"
    xml = HTTParty.get(dcc_news_feed_url).body
    @dcc_news_feed = Feedjira.parse(xml)
    respond_to do |format|
      format.rss { redirect_to dcc_news_feed_url }
      format.html
    end
  end

  def contact_us
  end

  def privacy
  end

  def termsuse
  end

  def help
  end

end
