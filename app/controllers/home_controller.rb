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
    end
    
    # Retrieve the images for the carousel
    @carousel_images = Dir.entries('./lib/assets/images/carousel').select{ |f| f.end_with?('.png') || f.end_with?('.jpg') }
    
    # Retrieve/cache the DMPTool blog's latest posts
    @rss = Rails.cache.read('rss')
    if @rss.nil?
      begin
        rss_xml = open(Rails.application.config.rss).read
        @rss = RSS::Parser.parse(rss_xml, false).items.first(5)
        Rails.cache.write("rss", @rss, :expires_in => 15.minutes)
      rescue Exception => e
        logger.error("Caught exception RSS parse: #{e}.")
      end
    end
    
    @orgs = Org.where('is_other IS NULL OR is_other = 0').order(:name)
  end

end
