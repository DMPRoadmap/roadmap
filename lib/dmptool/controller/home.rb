# frozen_string_literal: true

require 'rss'

module Dmptool

  module Controller

    module Home

      protected

      def render_home_page
        # Usage stats
        @stats = Rails.cache.read("stats") || {}
        if @stats.empty?
          @stats = statistics
        end

        # Top 5 templates
        @top_5 = Rails.cache.read("top_5")
        if @top_5.nil?
          @top_5 = top_templates
        end

        # Retrieve/cache the DMPTool blog's latest posts
        @rss = Rails.cache.read("rss")
        if @rss.nil?
          @rss = feed
        end

        render "home/index"
      end

      private

      # Collect general statistics about the application
      def statistics
        stats = {
          user_count: User.select(:id).count,
          completed_plan_count: Plan.select(:id).count,
          institution_count: Org.select(:id).count
        }
        cache_content("stats", stats)
        stats
      end

      # Collect  the list of the top 5 most used templates for the past 90 days
      def top_templates
        end_date = Date.today
        start_date = (end_date - 90)
        ids = Plan.group(:template_id)
                  .where(created_at: start_date..end_date)
                  .order("count_id DESC")
                  .count(:id).keys

        top_5 = Template.where(id: ids[0..4])
                        .pluck(:title)
        cache_content("top_5", top_5)
        top_5
      end

      # Get the last 5 blog posts
      def feed
        begin
          xml = open(Rails.application.config.rss).read
          rss = RSS::Parser.parse(xml, false).items.first(5)
          cache_content("rss", rss)

        rescue Exception
          # If we were unable to connect to the blog rss
          rss = [] if rss.nil?
          logger.error("Caught exception RSS parse: #{e}.")
        end
        rss
      end

      # Store information in the cache
      def cache_content(type, data)
        begin
          Rails.cache.write(type, data, expires_in => 60.minutes)
        rescue Exception => e
          logger.error("Unable to add #{type} to the Rails cache: #{e}.")
        end
      end

    end

  end

end
