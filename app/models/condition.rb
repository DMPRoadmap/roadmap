# == Schema Information
#
# Table name: conditions
#
#  id                 :integer          not null, primary key
#  action_type        :integer
#  number             :integer
#  webhook_data       :string
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
  belongs_to :question_option # replace with has_and_belongs_to_many :question_options
  has_one :question, through: :question_option
  belongs_to :remove_question, class_name: "Question" # replace with has_many :remove_questions, class_name: "Question"
  enum action_type: [:remove, :add_webhook]

  def deep_copy(**options)
  	copy = self.dup
  	copy.question_option_id = options.fetch(:question_option_id, nil)
  	copy.save!(validate: false) if options.fetch(:save, false)
  	copy
  end
end
