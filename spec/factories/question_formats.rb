# == Schema Information
#
# Table name: question_formats
#
#  id           :integer          not null, primary key
#  title        :string
#  description  :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  option_based :boolean          default(FALSE)
#  formattype   :integer          default(0)
#

FactoryBot.define do
  factory :question_format do
    title { Faker::Lorem.words(3).join }
    description { Faker::Lorem.sentence }
    formattype { QuestionFormat::FORMAT_TYPES.sample }
  end
end
