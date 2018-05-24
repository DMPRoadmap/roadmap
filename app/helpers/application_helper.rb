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
  
  # ---------------------------------------------------------------------------
  def hash_to_js_json_variable(obj_name, hash)
    "<script type=\"text/javascript\">var #{obj_name} = #{hash.to_json};</script>".html_safe
  end

  # Determines whether or not the URL path passed matches with the full path (including params) of the last URL requested.
  # see http://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-fullpath for details
  # ---------------------------------------------------------------------------
  def isActivePage(path, exact_match = false)
    if exact_match
      return request.fullpath == path
    else
      return request.fullpath.include?(path)
    end
  end

  def is_integer?(string)
    return string.present? && string.match(/^(\d)+$/)
  end

  def fingerprinted_asset(name)

  # START DMPTool customization
  # ---------------------------------------------------------
    #Rails.env.production? ? "#{name}-#{ASSET_FINGERPRINT}" : name
    Rails.application.config.use_fingerprinted_assets ? "#{name}-#{ASSET_FINGERPRINT}" : name
  # ---------------------------------------------------------
  # END DMPTool customization

  end
end
