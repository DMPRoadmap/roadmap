class NewPhase < ActiveRecord::Base
  belongs_to :template
  has_many :new_sections
end
