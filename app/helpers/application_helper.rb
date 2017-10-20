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
  def isActivePage(path)
    return request.fullpath() == path
  end

  # This is not the most elegant solution. Bootstrap though seems to add a '-tab' suffix
  # to the end of the query string param, so just strip it out when comparing
  # ---------------------------------------------------------------------------
  def isActiveTab(tab)
    qs = request.query_string.split('&').select{ |p| p.start_with?('tab=') }
    active = qs.first.gsub('tab=', '').gsub('-tab', '') if qs.size > 0
    return "#{tab}" == "#{active}"
  end

  def fingerprinted_asset(name)
    Rails.env.production? ? "#{name}-#{ASSET_FINGERPRINT}" : name
  end
end
