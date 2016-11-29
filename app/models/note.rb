class Notes < ActiveRecord::Base
  belongs_to :new_answer
  belongs_to :user
end
