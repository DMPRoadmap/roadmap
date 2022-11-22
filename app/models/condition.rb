# frozen_string_literal: true

# == Schema Information
#
# Table name: conditions
#
#  id           :integer          not null, primary key
#  action_type  :integer
#  number       :integer
#  option_list  :text(65535)
#  remove_data  :text(65535)
#  webhook_data :text(65535)
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

# Object that represents a condition of a conditional question
class Condition < ApplicationRecord
  belongs_to :question
  enum action_type: { remove: 0, add_webhook: 1 }
  serialize :option_list, Array
  serialize :remove_data, Array
  serialize :webhook_data, JSON

  # Sort order: Number ASC
  default_scope { order(number: :asc) }

  def deep_copy(**options)
    copy = dup
    copy.question_id = options.fetch(:question_id, nil)
    # TODO: why call validate false here
    copy.save!(validate: false) if options.fetch(:save, false)
    copy
  end
end
