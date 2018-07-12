# == Schema Information
#
# Table name: notifications
#
#  id                :integer          not null, primary key
#  notification_type :integer
#  title             :string
#  level             :integer
#  body              :text
#  dismissable       :boolean
#  starts_at         :date
#  expires_at        :date
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryBot.define do
  factory :notification do
    notification_type { :global }
    title { Faker::Lorem.sentence }
    level { :info }
    body { Faker::Lorem.paragraph }
    dismissable true
    starts_at { Time.current }
    expires_at { 1.day.from_now }
  end
end
