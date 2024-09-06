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

# Object that represents a condition of a conditional question
class Condition < ApplicationRecord
  belongs_to :question
  enum action_type: %i[remove add_webhook]
  serialize :option_list, Array
  serialize :remove_data, Array
  serialize :webhook_data, JSON

  # Sort order: Number ASC
  default_scope { order(number: :asc) }
  # rubocop:disable Metrics/AbcSize
  def deep_copy(**options)
    copy = dup
    copy.question_id = options.fetch(:question_id, nil)
    # Added to allow options to be passed in for all fields
    copy.option_list = options.fetch(:option_list, option_list) if options.key?(:option_list)
    copy.remove_data = options.fetch(:remove_data, remove_data) if options.key?(:remove_data)
    copy.action_type = options.fetch(:action_type, action_type) if options.key?(:action_type)
    copy.webhook_data = options.fetch(:webhook_data, webhook_data) if options.key?(:webhook_data)
    # TODO: why call validate false here
    copy.save!(validate: false) if options.fetch(:save, false)
    copy
  end
  # rubocop:enable Metrics/AbcSize
end
