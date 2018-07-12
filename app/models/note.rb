class Note < ActiveRecord::Base
  ##
  # Associations
  belongs_to :answer
  belongs_to :user


  validates :text, :answer, :user, presence: {message: _("can't be blank")}

end
