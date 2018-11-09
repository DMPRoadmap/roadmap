# == Schema Information
#
# Table name: question_formats
#
#  id           :integer          not null, primary key
#  description  :text
#  formattype   :integer          default(0)
#  option_based :boolean          default(FALSE)
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :question_format do
    title { Faker::Lorem.words(3).join }
    description { "http://test.host" }
    formattype { QuestionFormat::FORMAT_TYPES.sample }

    # Ensures duplicates aren't created
    initialize_with do
      QuestionFormat.find_or_create_by(title: title,
                                       formattype: formattype)
    end

    trait :textarea do
      title { "Text area" }
      formattype { "textarea" }
    end

    trait :textfield do
      title { "Text field" }
      formattype { "textfield" }
    end

    trait :radiobuttons do
      title { "Radio buttons" }
      formattype { "radiobuttons" }
      option_based { true }
    end

    trait :checkbox do
      title { "Check box" }
      formattype { "checkbox" }
      option_based { true }
    end

    trait :dropdown do
      title { "Drop down" }
      formattype { "dropdown" }
      option_based { true }
    end

    trait :multiselectbox do
      title { "Multi select box" }
      formattype { "multiselectbox" }
      option_based { true }
    end

    trait :date do
      title { "Date" }
      formattype { "date" }
    end

    trait :rda_metadata do
      title { "RDA Metadata" }
      formattype { "rda_metadata" }
    end

  end
end
