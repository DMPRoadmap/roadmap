class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include GlobalHelpers
  
  helper_method GlobalHelpers.instance_methods

  # Override build_footer method in ActiveAdmin::Views::Pages
  require 'active_admin_views_pages_base.rb'

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  before_filter :set_locale

  after_filter :store_location

  def set_locale
    # parameter from url takes precedence
    # check if locale is defined
    if params[:locale] # and I18n.available_locales.include? params[:locale] # throw an error if not available
      # if locales data is present in the parameter from url use it
      I18n.locale = params[:locale]
    elsif user_signed_in? and !current_user[:language_id].nil?
      I18n.locale = Language.find_by_id(current_user[:language_id]).abbreviation
      # if user has set preferred language use it
    elsif user_signed_in? and current_user.organisation.present? and !current_user.organisation[:language_id].nil?
      I18n.locale = Language.find_by_id(current_user.organisation[:language_id]).abbreviation
      # use user's organization language, keep in mine the "OTHER ORG" edge case which should use default language
    else
      # just use the default language, line can be commented out, included just for clarity
      I18n.locale = I18n.default_locale
    end
  end

  # Added setting for passing local params across pages
  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    if (request.fullpath != "/users/sign_in" && \
			 request.fullpath != "/users/sign_up" && \
			 request.fullpath != "/users/password" && \
            request.fullpath != "/users/sign_up?nosplash=true" && \
			 !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    session[:previous_url] || root_path
  end

  def after_sign_up_path_for(resource)
    session[:previous_url] || root_path
  end

  def after_sign_in_error_path_for(resource)
    session[:previous_url] || root_path
  end

  def after_sign_up_error_path_for(resource)
    session[:previous_url] || root_path
  end

  def authenticate_admin!
    redirect_to root_path unless user_signed_in? && current_user.is_admin?
  end

  def get_plan_list_columns
    if user_signed_in?
      @selected_columns = current_user.settings(:plan_list).columns
      @all_columns = Settings::PlanList::ALL_COLUMNS
    end
  end
end
