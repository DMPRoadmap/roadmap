class ContactsController < ContactUs::ContactsController

  # in order to i18 this file recaptcha gem has to be updated

	def create
		@contact = ContactUs::Contact.new(params[:contact_us_contact])
		if (!user_signed_in?)
			if verify_recaptcha(:message => "You have not added the validation words correctly") && @contact.save
				flash[:notice] = t('contact_us.notices.success')
				if user_signed_in? then
			  		redirect_to :controller => 'projects', :action => 'index'
			  	else
			  		redirect_to(root_path)
			  	end
			else
			  	flash[:alert]  = t('contact_us.notices.error')
			  	render_new_page
			end
		else
			if @contact.save
				flash[:notice] = t('contact_us.notices.success')
				if user_signed_in? then
			  		redirect_to :controller => 'projects', :action => 'index'
			  	else
			  		redirect_to(root_path)
			  	end
			else
			  	flash[:alert] = t('contact_us.notices.error')
			  	render_new_page
			end
		end		
	end
end