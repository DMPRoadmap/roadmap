class Note < ActiveRecord::Base
  belongs_to :new_answer
  belongs_to :user
end
