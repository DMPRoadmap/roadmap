module ApplicationHelper
	def resource_name
		:user
	end

	def resource
		@resource ||= User.new
	end

	def devise_mapping
		@devise_mapping ||= Devise.mappings[:user]
	end
	
	def javascript(*files)
	  content_for(:head) { javascript_include_tag(*files) }
	end
  
  def link_to_add_object(name, f, association, css_class, i)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      j = i + 1
      new_object.number = j
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_object(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class => css_class)
  end
  
  def link_to_function(name, *args, &block)
    html_options = args.extract_options!.symbolize_keys

    function = block_given? ? update_page(&block) : args[0] || ''
    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
    href = html_options[:href] || '#'

    content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
  end
  
  def hash_to_json_object(obj_name, hash)
    
puts hash
puts hash.to_json
    
    "<script type=\"text/javascript\">var #{obj_name} = #{hash.to_json};</script>".html_safe
  end
end
