# frozen_string_literal: true

# == Schema Information
#
# Table name: research_domains
#
#  id         :bigint(8)        not null, primary key
#  identifier :string(255)      not null
#  label      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :bigint(8)
#
# Indexes
#
#  index_research_domain_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => research_domains.id)
#
FactoryBot.define do
  factory :research_domain do
    identifier { SecureRandom.uuid }
    label { Faker::Lorem.unique.word }
    uri { Faker::Internet.url }
  end
end
