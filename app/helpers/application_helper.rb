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

	
end
