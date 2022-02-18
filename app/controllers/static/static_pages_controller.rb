module Static
  class StaticPagesController < ApplicationController
    before_action :set_static_page, only: :show

    # GET /static/:name
    def show; end

    private

    # Define static page to be rendered, 404 if needed
    def set_static_page
      @static_page = StaticPage.find_by(url: params[:name])
      render file: "#{Rails.root}/public/404", status: 404 unless @static_page
    end
  end
end
