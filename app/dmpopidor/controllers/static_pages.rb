module Dmpopidor
  module Controllers
    module StaticPages
      # Changed News feed
      def news_feed
        news_feed_url = "https://opidor.fr/category/dmp-news/feed/"
        xml = HTTParty.get(news_feed_url).body
        @news_feed = Feedjira.parse(xml)
        respond_to do |format|
          format.rss { redirect_to news_feed_url }
          format.html
        end
      end
    
      # Added Tutorials Page
      def tutorials
  
      end

      def optout

      end
    end
  end
end