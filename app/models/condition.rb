# frozen_string_literal: true

# == Schema Information
#
# Table name: conditions
#
#  id                 :integer          not null, primary key
#  question_id        :integer
#  number             :integer
#  action_type        :integer
#  option_list        :text
#  remove_data        :text
#  webhook_data       :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_conditions_on_question_id  (question_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => question.id)
#
#

class Condition < ApplicationRecord

  belongs_to :question
  enum action_type: %i[remove add_webhook]
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
