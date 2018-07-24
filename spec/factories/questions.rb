# == Schema Information
#
# Table name: questions
#
#  id                     :integer          not null, primary key
#  text                   :text
#  default_value          :text
#  number                 :integer
#  section_id             :integer
#  created_at             :datetime
#  updated_at             :datetime
#  question_format_id     :integer
#  option_comment_display :boolean          default(TRUE)
#  modifiable             :boolean
#

FactoryBot.define do
  factory :question do
    section
    question_format
    text { Faker::Lorem.paragraph }
    sequence(:number)
    modifiable false
    trait :textarea do
      question_format {
        QuestionFormat
          .where(formattype: "textarea")
          .first_or_create(title: "Text Area", description: "Text area")
      }
    end
  end
end
