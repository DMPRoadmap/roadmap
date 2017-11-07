class Note < ActiveRecord::Base
  ##
  # Associations
  belongs_to :answer
  belongs_to :user

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :text, :user_id, :answer_id, :archived, :archived_by, 
                  :answer, :user, :as => [:default, :admin]
                  
  validates :text, :answer, :user, presence: {message: _("can't be blank")}

  # Active Record Callbacks
  after_create do
    # Sends an email to the plan owner regarding a new comment created by new note user
    UserMailer.new_comment(self.user, self.answer.plan).deliver_now()
  end
end
