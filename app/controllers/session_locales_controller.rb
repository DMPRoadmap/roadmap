# frozen_string_literal: true

class SessionLocalesController < ApplicationController

  def update
    session[:locale] = params[:locale] if available_locales.include?(param_locale)
    redirect_to(:back)
  end

  private

  def available_locales
    LocaleSet.new(FastGettext.default_available_locales).for(:fast_gettext)
  end

  def param_locale
    LocaleFormatter.new(params[:locale], format: :fast_gettext).to_s
  end

end
