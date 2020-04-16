# frozen_string_literal: true

class StaticPagesController < ApplicationController

  # --------------------------------
  # Start DMPTool Customization
  # --------------------------------
  include Dmptool::Controllers::StaticPagesController
  # --------------------------------
  # End DMPTool Customization
  # --------------------------------

  def about_us
  end

  def contact_us
  end

  def privacy
  end

  def termsuse
  end

  def help
  end

end
