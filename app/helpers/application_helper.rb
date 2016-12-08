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
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end
  
  # ---------------------------------------------------------------------------
  def hash_to_js_json_variable(obj_name, hash)
    "<script type=\"text/javascript\">var #{obj_name} = #{hash.to_json};</script>".html_safe
  end
end
