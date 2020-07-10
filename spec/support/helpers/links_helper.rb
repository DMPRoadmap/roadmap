# frozen_string_literal: true

module LinksHelper

  def add_link
    click_link "+ Add an additional URL"
  end

  def remove_link
    all(".link a > .fa-times-circle").last.click
  end

end
