class Role < ActiveRecord::Base
  include FlagShihTzu


  ##
  # Associations
  belongs_to :user
  belongs_to :plan

  ##
  # Define Bit Field Values
  # Column access
  has_flags 1 => :creator,
            2 => :administrator,
            3 => :editor,
            4 => :commenter,
            column: 'access'

  validates :user, :plan, :access, presence: true
  validates :access, numericality: {greater_than: 0}

  
end
