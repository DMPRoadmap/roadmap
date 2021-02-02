# frozen_string_literal: true

module ApplicationHelper

  def resource_name
    :user
  end

  # ---------------------------------------------------------------------------
  def resource
    @resource ||= User.new
  end

  # ---------------------------------------------------------------------------
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  # Determines whether or not the URL path passed matches with the full path (including
  # params) of the last URL requested. See
  # http://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-fullpath
  # for details
  def active_page?(path, exact_match = false)
    if exact_match
      request.fullpath == path
    else
      request.fullpath.include?(path)
    end
  end

  alias isActivePage active_page?

  deprecate :isActivePage, deprecator: Cleanup::Deprecators::PredicateDeprecator.new

  def fingerprinted_asset(name)
    Rails.env.production? ? "#{name}-#{ASSET_FINGERPRINT}" : name
  end

  def title(page_title)
    content_for(:title) { page_title }
  end


  # This method assumes there will be an image file called dmp_logo_xx_XX.png
  # Where xx_XX is the current locale in ww-WW format. Examples of this are
  # en_CA, fr_CA
  def current_locale_logo
    file_name = "dmp_logo_#{FastGettext.locale}.png"
  end

  # We are overriding this method in order to provide different contact us urls
  # based on the chosen locale. Using the branding.yml does not work for this as
  # we need different urls. This will be changed when we move to DMPRoadmap 3.0 
  # as there is a service that handles fetching this information.
  def contact_us_path
    if (FastGettext.locale == 'fr_CA') 
      'https://portagenetwork.ca/fr/contactez-nous/'
    else
      # Handling 'en_CA' locale
      'https://portagenetwork.ca/contact-us/'
    end
  end

  def unique_dom_id(record, prefix = nil)
    klass     = dom_class(record, prefix)
    record_id = record_key_for_dom_id(record) || record.object_id
    "#{klass}_#{record_id}"
  end

end
