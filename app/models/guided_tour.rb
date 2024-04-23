# == Schema Information
#
# Table name: guided_tours
#
#  id         :bigint(8)        not null, primary key
#  ended      :boolean          default(FALSE)
#  tour       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)
#
# Indexes
#
#  index_guided_tours_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class GuidedTour < ApplicationRecord
  belongs_to :user
end
