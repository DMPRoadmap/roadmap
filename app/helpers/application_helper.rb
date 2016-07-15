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
end
