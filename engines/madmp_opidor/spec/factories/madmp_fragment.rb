# frozen_string_literal: true


FactoryBot.define do
  factory :madmp_fragment do
    data { { } }
    classname { nil }
    dmp_id
    parent_id
    madmp_schema
  end
end
