# frozen_string_literal: true

module Dmptool

  class StaticPagesController < ApplicationController

    def about_us
      dcc_news_feed_url = "http://www.dcc.ac.uk/news/dmponline-0/feed"
      @dcc_news_feed = Feedjira::Feed.fetch_and_parse dcc_news_feed_url
      respond_to do |format|
        format.rss { redirect_to dcc_news_feed_url }
        format.html { render 'static_pages/about_us' }
      end
    end

    def contact_us
      render 'contact_us/contacts/new'
    end

    def roadmap
      render 'static_pages/roadmap'
    end

    def privacy
      render 'static_pages/privacy'
    end

    def termsuse
      render 'static_pages/termsuse'
    end

    def help
      render 'static_pages/help'
    end

    def promote
      render 'static_pages/promote'
    end

    def researchers
      render 'static_pages/researchers'
    end

    def faq
      render 'static_pages/faq'
    end

    def general_guidance
      render 'static_pages/general_guidance'
    end

    def news_media
      render 'static_pages/news_media'
    end

  end

end
