# frozen_string_literal: true

class StaticPagesController < ApplicationController

  prepend Dmpopidor::Controllers::StaticPages

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
