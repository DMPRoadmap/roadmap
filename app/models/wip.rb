# frozen_string_literal: true

require 'securerandom'

# == Schema Information
#
# Table name: themes
#
#  id          :integer          not null, primary key
#  identifier  :string           not null
#  user_id     :integer
#  metadata    :json
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

# Object that represents a question/guidance theme
class Wip < ApplicationRecord
  before_save :generate_identifier if new_record?

  protected

  def generate_identifier
    throw(:abort) unless metadata.present? && user_id.present?

    identifier = "#{Time.now.strftime('%Y%m%d')}-#{SecureRandom.hex(6)}"
  end
end
