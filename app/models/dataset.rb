# == Schema Information
#
# Table name: datasets
#
#  id          :integer          not null, primary key
#  description :text
#  is_default  :boolean          default(FALSE)
#  name        :string
#  order       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  plan_id     :integer
#
# Indexes
#
#  index_datasets_on_plan_id  (plan_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#

class Dataset < ActiveRecord::Base
    belongs_to :plan
    has_many :answers, dependent: :destroy

    default_scope { order(order: :asc) }
  
    def main?
      eql?(plan.datasets.where(order: 1).first)
    end

    # Return main dataset
    def get_main
      plan.datasets.first
    end

    def has_common_answers?(section_id)
      self.answers.each do |answer|
        if answer.question_id.in?(Section.find(section_id).questions.pluck(:id)) && answer.is_common
          return true
        end
      end
      return false
    end

    ##
    # deep copy the given dataset
    #
    # Returns Dataset
    def self.deep_copy(dataset)
      dataset.dup
    end

  end
