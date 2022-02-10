# frozen_string_literal: true

class StaticPagesController < ApplicationController

  # --------------------------------
  # Start DMP OPIDoR Customization
  # SEE app/controllers/dmpopidor/static_pages_controller.rb
  # --------------------------------
  prepend Dmpopidor::StaticPagesController
  # --------------------------------
  # End DMP OPIDoR Customization
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
