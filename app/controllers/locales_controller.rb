class LocalesController < ApplicationController

  def change_session_locale
    if params[:locale]
      session[:locale] = params[:locale]
      redirect_to :back
    end
  end

end