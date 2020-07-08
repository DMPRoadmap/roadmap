# frozen_string_literal: true

class SessionLocalesController < ApplicationController

  def update
    session[:locale] = params[:locale] if available_locales.include?(param_locale)
    redirect_back(fallback_location: root_path)
  end

  private

  def available_locales
    FastGettext.default_available_locales.map do |locale|
      LocaleService.to_gettext(locale: locale).to_s
    end
  end

  def param_locale
    LocaleService.to_gettext(locale: params[:locale]).to_s
  end

end
