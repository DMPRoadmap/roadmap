# == Schema Information
#
# Table name: fos
#
#  id         :bigint(8)        not null, primary key
#  identifier :string(255)      not null
#  keywords   :text(65535)
#  label      :string(255)      not null
#  uri        :string(255)      default("")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :bigint(8)
#
# Indexes
#
#  index_fos_on_parent_id  (parent_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => fos.id)
#
FactoryBot.define do
  factory :field_of_science do
    identifier { SecureRandom.uuid }
    keywords { [Faker.lorem.unique.word, Faker.lorem.unique.word].join(" ") }
    label { Faker::Lorem.uniwue.word }
    uri { Faker::Internet.url }
  end
end
