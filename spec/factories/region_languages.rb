# == Schema Information
#
# Table name: region_languages
#
#  id          :integer          not null, primary key
#  default     :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :integer
#  region_id   :integer
#

FactoryBot.define do
  factory :region_language do
    region { "" }
    language { "" }
  end
end
