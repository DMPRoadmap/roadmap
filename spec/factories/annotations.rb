# frozen_string_literal: true

# == Schema Information
#
# Table name: annotations
#
#  id             :integer          not null, primary key
#  text           :text(65535)
#  type           :integer          default("example_answer"), not null
#  created_at     :datetime
#  updated_at     :datetime
#  org_id         :integer
#  question_id    :integer
#  versionable_id :string(36)
#
# Indexes
#
#  fk_rails_aca7521f72                  (org_id)
#  index_annotations_on_question_id     (question_id)
#  index_annotations_on_versionable_id  (versionable_id)
#

FactoryBot.define do
  factory :annotation do
    question
    org
    text { Faker::Lorem.paragraph }
    type { [0, 1].sample }
  end
end
