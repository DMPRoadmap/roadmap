# frozen_string_literal: true

# == Schema Information
#
# Table name: subscribers
#
#  id                :bigint           not null, primary key
#  callback_uri      :string
#  identifiable_type :string
#  subscription_type :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  identifiable_id   :bigint
#  plan_id           :bigint
#
# Indexes
#
#  index_subscribers_on_identifiable_and_plan_id  (identifiable_id,identifiable_type,plan_id)
#  index_subscribers_on_plan_id                   (plan_id)
#
class Subscriber < ApplicationRecord

end
