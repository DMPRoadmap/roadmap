# frozen_string_literal: true

# Registry of DMP IDs that a user has asked us to hide from their dashboard pages
#
# == Schema Information
#
# Table name: guidances
#
#  user_id           :integer          not null
#  dmp_id            :string           not_null
#
# Indexes
#
#  index_hidden_dmps_on_dmp_id  (dmp_id)
#  index_hidden_dmps_on_user_id_dmp_id  (user_id, dmp_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class HiddenDmp < ApplicationRecord
  belongs_to :user

  validates :user, :dmp_id, presence: { message:  PRESENCE_MESSAGE }
end
