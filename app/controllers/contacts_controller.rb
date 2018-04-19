class ContactUs::ContactsController < ApplicationController

  def create
    @contact = ContactUs::Contact.new(params[:contact_us_contact])
    flash[:alert] = nil

    if !user_signed_in? && !verify_recaptcha(model: @contact)
      flash[:alert] = _('Captcha verification failed, please retry.')
    end

    if !flash[:alert].present? && @contact.save
      redirect_to(ContactUs.success_redirect || '/', :notice => _('Contact email was successfully sent.'))
    else
      flash[:alert] = _('Unable to submit your request') unless flash[:alert].present?
      render 'new'
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
