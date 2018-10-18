# == Schema Information
#
# Table name: notifications
#
#  id                :integer          not null, primary key
#  body              :text
#  dismissable       :boolean
#  expires_at        :date
#  level             :integer
#  notification_type :integer
#  starts_at         :date
#  title             :string
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
