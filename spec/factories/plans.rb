# == Schema Information
#
# Table name: plans
#
#  id                                :integer          not null, primary key
#  complete                          :boolean          default(FALSE)
#  data_contact                      :string
#  data_contact_email                :string
#  data_contact_phone                :string
#  description                       :text
#  feedback_requested                :boolean          default(FALSE)
#  funder_name                       :string
#  grant_number                      :string
#  identifier                        :string
#  principal_investigator            :string
#  principal_investigator_email      :string
#  principal_investigator_identifier :string
#  principal_investigator_phone      :string
#  title                             :string
#  visibility                        :integer          default(3), not null
#  created_at                        :datetime
#  updated_at                        :datetime
#  template_id                       :integer
#
# Indexes
#
#  index_plans_on_template_id  (template_id)
#
# Foreign Keys
#
#  fk_rails_...  (template_id => templates.id)
#

FactoryBot.define do
  factory :plan do
    title { Faker::Company.bs }
    template
    grant_number { SecureRandom.rand(1_000) }
    identifier { SecureRandom.hex }
    description { Faker::Lorem.paragraph }
    principal_investigator { Faker::Name.name }
    funder_name { Faker::Company.name }
    data_contact_email { Faker::Internet.safe_email }
    principal_investigator_email { Faker::Internet.safe_email }
    feedback_requested false
    complete false
    transient do
      answers 0
      guidance_groups 0
    end
    trait :creator do
      after(:create) { |obj| obj.roles << create(:role, creator: true) }
    end
    trait :commenter do
      after(:create) { |obj| obj.roles << create(:role, commenter: true) }
    end

    trait :organisationally_visible do
      visibility "organisationally_visible"
    end

    trait :publicly_visible do
      visibility "publicly_visible"
    end

    trait :is_test do
      visibility "is_test"
    end

    trait :privately_visible do
      visibility "privately_visible"
    end

    after(:create) do |plan, evaluator|
      create_list(:answer, evaluator.answers, plan: plan)
    end

    after(:create) do |plan, evaluator|
      plan.guidance_groups << create_list(:guidance_group, evaluator.guidance_groups)
    end

  end
end
