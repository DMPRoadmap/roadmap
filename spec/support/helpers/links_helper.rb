# frozen_string_literal: true

module LinksHelper

  def addLink
    click_link "+ Add an additional URL"
  end

  def removeLink
    all(".link a > .fa-times-circle").last.click
  end

end
