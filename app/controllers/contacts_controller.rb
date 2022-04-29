# frozen_string_literal: true

module ContactUs
  # Controller for the Contact Us gem
  class ContactsController < ApplicationController
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def create
      @contact = ContactUs::Contact.new(params[:contact_us_contact])

      if !user_signed_in? && Rails.configuration.x.recaptcha.enabled &&
         !(verify_recaptcha(model: @contact) && @contact.save)
        flash[:alert] = _('Captcha verification failed, please retry.')
        render_new_page and return
      end
      if @contact.save
        redirect_to(ContactUs.success_redirect || '/',
                    notice: _('Contact email was successfully sent.'))
      else
        flash[:alert] = _('Unable to submit your request')
        render_new_page
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

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
end
