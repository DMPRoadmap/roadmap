class Role < ActiveRecord::Base
  include FlagShihTzu

  ##
  # Associationsrequire "role"
  
  belongs_to :user
  belongs_to :plan

  ##
  # Define Bit Field Values
  # Column access
  has_flags 1 => :creator,            # 1
            2 => :administrator,      # 2
            3 => :editor,             # 4
            4 => :commenter,          # 8
            column: 'access'

  validates :user, :plan, :access, presence: {message: _("can't be blank")}
  validates :access, numericality: {greater_than: 0, message: _("can't be less than zero")}

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

# -----------------------------------------------------
# Bitwise key
# -----------------------------------------------------
# 01 - creator
# 02 - administrator
# 03 - creator + administrator
# 04 - editor
# 05 - creator + editor
# 06 - administraor + editor
# 07 - creator + editor + administrator
# 08 - commenter
# 09 - creator + commenter
# 10 - administrator + commenter
# 11 - creator + administrator + commenter
# 12 - editor + commenter
# 13 - creator + editor + commenter
# 14 - administrator + editor + commenter
# 15 - creator + administrator + editor + commenter