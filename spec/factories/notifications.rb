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
    dismissable false
    starts_at { Time.current }
    expires_at { starts_at + 2.days  }

    trait :active do
      starts_at { Date.today }
    end
    trait :dismissable do
      dismissable true
    end
  end
end
