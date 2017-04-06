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

  ##
  # return the access level for the current project group
  # 3 if the user is an administrator
  # 2 if the user is an editor
  # 1 if the user can only read
  # used to facilliatte formtastic
  #
  # @return [Integer]
  def access_level
    if self.administrator?
      return 3
    elsif self.editor?
      return 2
    elsif self.commenter?
      return 1
    end
  end

end
