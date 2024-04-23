# frozen_string_literal: true

module Static
  # Controller that handles requests for static pages
  class StaticPagesController < ApplicationController
    # before_action :set_static_page, only: :show

    prepend_view_path 'app/views/branded/static'

    # GET /static/:name
    def show
      @page = params[:name]
      render "show"
    end

    private

    # Define static page to be rendered, 404 if needed
    # def set_static_page
    #   @static_page = StaticPage.find_by(url: params[:name])
    #   render file: "#{Rails.root}/public/404.html", status: 404 unless @static_page
    # end
  end
end
