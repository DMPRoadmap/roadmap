# == Schema Information
#
# Table name: conditions
#
#  id           :integer          not null, primary key
#  action_type  :integer
#  number       :integer
#  option_list  :text
#  remove_data  :text
#  webhook_data :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  question_id  :integer
#
# Indexes
#
#  index_conditions_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => questions.id)
#

class Condition < ActiveRecord::Base
  belongs_to :question
  enum action_type: [:remove, :add_webhook]
  serialize :option_list, Array
  serialize :remove_data, Array
  serialize :webhook_data, JSON

  # Sort order: Number ASC
  default_scope { order(number: :asc) }

  def deep_copy(**options)
  	copy = self.dup
  	copy.question_id = options.fetch(:question_id, nil)
  	copy.save!(validate: false) if options.fetch(:save, false)
  	copy
  end
end
