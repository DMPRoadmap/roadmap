# frozen_string_literal: true

class SessionLocalesController < ApplicationController

  def update
    session[:locale] = params[:locale] if available_locales.include?(params[:locale].intern)
    redirect_to(:back)
  end

  private

  def available_locales
    I18n.available_locales
  end

end
