# frozen_string_literal: true

module ContactUs
  # Controller for the Contact Us gem
  class ContactsController < ApplicationController
    def new
      @contact = ContactUs::Contact.new
      render_new_page
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def create
      @contact = ContactUs::Contact.new(params[:contact_us_contact])

      if !user_signed_in? && Rails.configuration.x.recaptcha.enabled &&
         !(verify_recaptcha(action: 'contact') && @contact.save)
        flash.now[:alert] = _('Invalid security check! Please make sure your browser is up to date and then try again')
        render_new_page and return
      end
      if @contact.save
        redirect_to(ContactUs.success_redirect || '/',
                    notice: _('Contact email was successfully sent.'))
      else
        flash.now[:alert] = _('Unable to submit your request')
        render_new_page
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

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
end
