# frozen_string_literal: true

# Controller that handles requests for static pages
class StaticPagesController < ApplicationController
  def about_us; end

  # --------------------------------
  # Start DMPTool Customization
  # --------------------------------
  include Dmptool::StaticPagesController
  # --------------------------------
  # End DMPTool Customization
  # --------------------------------

  def about_us
  end

  def privacy; end

  def termsuse; end

  def help; end
end
