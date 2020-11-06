# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base

  include GlobalHelpers
  include ValidationValues
  include ValidationMessages

  self.abstract_class = true

end
