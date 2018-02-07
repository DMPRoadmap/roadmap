require 'rss'

class HomeController < ApplicationController
  respond_to :html

  ##
  # Index
  #
  # Currently redirects user to their list of projects
  # UNLESS
  # User's contact name is not filled in
  # Is this the desired behavior?
  def index
    if user_signed_in?
      name = current_user.name(false)
# TODO: Investigate if this is even relevant anymore. The name var will never be blank here because the logic in
#       User says to return the email if the firstname and surname are empty regardless of the flag passed in
      if name.blank?
        redirect_to edit_user_registration_path
      else
        redirect_to plans_url
      end
    else
    
      # Usage stats
      stats = Rails.cache.read('stats') || {}
      if stats.empty?
        stats[:user_count] = User.select(:id).count
        stats[:completed_plan_count] = Plan.select(:id).count
        stats[:institution_count] = Org.select(:id).count
        cache_content('stats', stats)
      end
    
      # Top 5 templates
      top_5 = Rails.cache.read('top_5')
      if top_5.nil?
        end_date = Date.today
        start_date = (end_date - 60)
        ids = Plan.group(:template_id).where('created_at BETWEEN ? AND ?', start_date, end_date).order('count_id DESC').count(:id).keys
        top_5 = Template.where(id: ids[0..4]).pluck(:title)
        cache_content('top_5', top_5)
      end
    
      # Retrieve/cache the DMPTool blog's latest posts
      rss = Rails.cache.read('rss')
      if rss.nil?
        rss_xml = open(Rails.application.config.rss).read
        rss = RSS::Parser.parse(rss_xml, false).items.first(5)
        cache_content('rss', rss)  
      end

      render 'index', locals: { stats: stats, top_5: top_5, rss: rss } 
    end
  end


  private
  def cache_content(type, data)
    begin
      Rails.cache.write(type, data, :expires_in => 15.minutes)
    rescue Exception => e
      logger.error("Caught exception RSS parse: #{e}.")
    end
  end

end
