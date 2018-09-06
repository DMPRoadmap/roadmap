# frozen_string_literal: true

class SessionLocalesController < ApplicationController

  def update
    if FastGettext.default_available_locales.include?(params[:locale])
      session[:locale] = params[:locale]
    end
    redirect_to(:back)
  end

end
