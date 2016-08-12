class Comment < ActiveRecord::Base

    #associations between tables
    belongs_to :question
    
    #fields
    attr_accessible :question_id, :text, :user_id, :archived, :plan_id, :archived_by, :as => [:default, :admin]

    
    
    def to_s
        "#{text}"
    end

end
