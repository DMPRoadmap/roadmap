class ContactUs::ContactsController < ApplicationController

  def create
    @contact = ContactUs::Contact.new(params[:contact_us_contact])
    flash[:alert] = nil

    if !user_signed_in?
      unless verify_recaptcha(model: @contact) && @contact.save
        flash[:alert] = _('Captcha verification failed, please retry.')
        render_new_page and return
      end
    end
    if @contact.save
      redirect_to(ContactUs.success_redirect || '/', :notice => _('Contact email was successfully sent.'))
    else
      flash[:alert] = _('Unable to submit your request')
      render_new_page
    end
  end

  def new
    @contact = ContactUs::Contact.new
    render_new_page
  end

  protected

    def render_new_page
      case ContactUs.form_gem
      when 'formtastic'  then render 'new_formtastic'
      when 'simple_form' then render 'new_simple_form'
      else
        render 'new'
      end
    end

end
