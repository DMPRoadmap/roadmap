# == Schema Information
#
# Table name: conditions
#
#  id                 :integer          not null, primary key
#  action_type        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  question_option_id :integer
#  remove_question_id :integer
#
# Indexes
#
#  index_conditions_on_question_option_id  (question_option_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_option_id => question_options.id)
#

class Condition < ActiveRecord::Base
  belongs_to :question_option
  has_one :question, through: :question_option
  belongs_to :remove_question, class_name: "Question" 
  enum action_type: [:remove, :add_webhook]
end
