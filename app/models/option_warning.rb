class OptionWarning < ActiveRecord::Base
  
  #associations between tables
  belongs_to :option
  belongs_to :organisation
  
# TODO: REMOVE AND HANDLE ATTRIBUTE SECURITY IN THE CONTROLLER!
  attr_accessible :text, :option_id, :organisation_id, 
                  :organisation, :option, :as => [:default, :admin]
  
  validates :organisation, :option, :text, presence: true
  
  def to_s
    "#{text}"
  end
end