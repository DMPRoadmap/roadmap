class ContactsController < ContactUs::ContactsController
  respond_to :html

  ##
  # create
  #
  # POST - Create a Contact Request
	def create
		@contact = ContactUs::Contact.new(params[:contact_us_contact])
		if (!user_signed_in?)
			if verify_recaptcha(message: "You have not added the validation words correctly") && @contact.save
				flash[:notice] = t('contact_us.notices.success')
			  redirect_to(root_path)
			else # recaptcha invalid or contact failed to save
        flash[:alert]  = t('contact_us.notices.error')
        render_new_page
			end
		else # no user signed in
			if @contact.save
				flash[:notice] = t('contact_us.notices.success')
			  redirect_to :controller => 'projects', :action => 'index'
			else # contact failed to save
			  flash[:alert] = t('contact_us.notices.error')
			  render_new_page
			end
		end
	end
end