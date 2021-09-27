# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base

  include GlobalHelpers
  include ValidationValues
  include ValidationMessages

  self.abstract_class = true

  def sanitize_fields(*attrs)
    attrs.each do |attr|
      send("#{attr}=", ActionController::Base.helpers.sanitize(send(attr)))
    end
  end

end
