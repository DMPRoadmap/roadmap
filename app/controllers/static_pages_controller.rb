# frozen_string_literal: true

# Controller that handles requests for static pages
class StaticPagesController < ApplicationController
  include Dmptool::StaticPagesController

  def about_us; end

  def privacy; end

  def termsuse; end

  def help; end
end
