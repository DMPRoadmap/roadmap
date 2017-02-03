class Role < ActiveRecord::Base
  include FlagShihTzu

  before_validation :check_access_level

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
            column: 'access'

  validates :user, :plan, :access, presence: true
  validates :access, numericality: {greater_than: 0}

  ##
  # return the access level for the current project group
  # 3 if the user is an administrator
  # 2 if the user is an editor
  # 1 if the user can only read
  #
  # @return [Integer]
  def access_level
    if self.administrator? then
      return 3
    elsif self.editor? then
      return 2
    else
      return 1
    end
  end

  ##
  # define a new access level for the current project group
  # if >=3, the user is a project administrator
  # if >=2, the user is an editor
  #
  # @param new_access_level [Integer] the access level to give the user
  def access_level=(new_access_level)
    new_access_level = new_access_level.to_i
    if new_access_level >= 3 then
      self.administrator = true
    else
      self.administrator = false
    end
    if new_access_level >= 2 then
      self.editor = true
    else
      self.editor = false
    end
    self.creator = true unless self.administrator? || self.editor?
  end
  
  # Ensures that the access attribute is set
  def check_access_level
    self.access_level = self.access_level
  end
end
