# frozen_string_literal: true

module Dmptool
  # Custom home page logic
  module HomeController
    def index
      if user_signed_in?
        redirect_to plans_path
      else
        # Specify any classes for the <main> tag of the page
        @main_class = 'js-heroimage'

        render 'home/index'
      end
    end

    # Simple handler for calls to robots.txt
    def robots
      respond_to :text
      expires_in 6.hours, public: true
    end
  end
end
