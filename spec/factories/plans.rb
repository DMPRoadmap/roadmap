# frozen_string_literal: true

# == Schema Information
#
# Table name: plans
#
#  id                                :integer          not null, primary key
#  complete                          :boolean          default(FALSE)
#  description                       :text
#  ethical_issues                    :boolean
#  ethical_issues_description        :text
#  ethical_issues_report             :string
#  feedback_requested                :boolean          default(FALSE)
#  funding_status                    :integer
#  identifier                        :string
#  title                             :string
#  visibility                        :integer          default(3), not null
#  created_at                        :datetime
#  updated_at                        :datetime
#  template_id                       :integer
#  org_id                            :integer
#  funder_id                         :integer
#  grant_id                          :integer
#  api_client_id                     :integer
#  research_domain_id                :bigint
#
# Indexes
#
#  index_plans_on_template_id   (template_id)
#  index_plans_on_funder_id     (funder_id)
#  index_plans_on_grant_id      (grant_id)
#  index_plans_on_api_client_id (api_client_id)
#
# Foreign Keys
#
#  fk_rails_...  (template_id => templates.id)
#  fk_rails_...  (org_id => orgs.id)
#  fk_rails_...  (api_client_id => api_clients.id)
#  fk_rails_...  (research_domain_id => research_domains.id)
#

FactoryBot.define do
  factory :plan do
    title { Faker::Company.bs }
    visibility { Plan.visibilities[:privately_visible] }
    template
    org
    identifier { SecureRandom.hex }
    description { Faker::Lorem.paragraph }
    feedback_requested { false }
    complete { false }
    start_date { Time.now }
    end_date { start_date + 2.years }
    ethical_issues { [true, false].sample }
    ethical_issues_description { Faker::Lorem.paragraph }
    ethical_issues_report { Faker::Internet.url }
    funding_status { Plan.funding_statuses.keys.sample }

    transient do
      phases { 0 }
      answers { 0 }
      guidance_groups { 0 }
    end

    %i[creator administrator editor commenter reviewer].each do |role|
      trait role do
        after(:create) do |obj|
          obj.roles << create(:role, role, user: create(:user, org: create(:org)))
        end
      end
    end

    %i[organisationally_visible publicly_visible is_test privately_visible].each do |visibility|
      trait visibility do
        after(:create) do |obj|
          obj.update(visibility: Plan.visibilities[visibility])
        end
      end
    end

    after(:create) do |plan, evaluator|
      create_list(:answer, evaluator.answers, plan: plan)
    end

    after(:create) do |plan, evaluator|
      plan.guidance_groups << create_list(:guidance_group, evaluator.guidance_groups)
    end
  end
end
