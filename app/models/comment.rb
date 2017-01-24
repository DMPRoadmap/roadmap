class Comment < ActiveRecord::Base

    #associations between tables
    belongs_to :user
    belongs_to :plan
    belongs_to :question
    
# TODO: REMOVE AND HANDLE ATTRIBUTE SECURITY IN THE CONTROLLER!
    attr_accessible :question_id, :text, :user_id, :archived, :plan_id, :archived_by, 
                    :user, :plan, :question, :as => [:default, :admin]

    validates :user, :question, :plan, :text, presence: true
    
    def to_s
        "#{text}"
    end

end
