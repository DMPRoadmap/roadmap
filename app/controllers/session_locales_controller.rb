# frozen_string_literal: true

class SessionLocalesController < ApplicationController

  def update
    session[:locale] = params[:locale] if available_locales.include?(param_locale)
    redirect_to(:back)
  end

  private

  def available_locales
    FastGettext.default_available_locales.map do |locale|
      LocaleService.to_gettext(string: locale).to_s
    end
  end

  def param_locale
    LocaleService.to_gettext(string: params[:locale]).to_s
  end

end
