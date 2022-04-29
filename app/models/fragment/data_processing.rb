# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_fragments

#  id                        :integer          not null, primary key
#  data                      :json
#  answer_id                 :integer
#  madmp_schema_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  classname                 :string
#  dmp_id                    :integer
#  parent_id                 :integer

# Indexes

#  index_madmp_fragments_on_answer_id                  (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)
module Fragment
  # DataProcessing STI model
  class DataProcessing < MadmpFragment
    def method_reference
      Fragment::ResourceReference.where(parent_id: id)
    end

    def facility
      Fragment::TechnicalResource.where(parent_id: id).first
    end

    def contributors
      Fragment::Contributor.where(parent_id: id)
    end

    def cost
      Fragment::Cost.where(parent_id: id)
    end

    def properties
      'method_reference, facility, contributors, cost'
    end

    def self.sti_name
      'data_processing'
    end
  end
end
