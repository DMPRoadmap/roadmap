# frozen_string_literal: true

require "httparty"
require "rss"

module Dmptool

  module HomeController

    def render_home_page
      # Specify any classes for the <main> tag of the page
      @main_class = "js-heroimage"

      render "home/index"
    end

  end

end
