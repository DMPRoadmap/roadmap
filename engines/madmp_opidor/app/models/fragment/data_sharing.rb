# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_fragments
#
#  id              :integer          not null, primary key
#  additional_info :json
#  classname       :string
#  data            :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  answer_id       :integer
#  dmp_id          :integer
#  madmp_schema_id :integer
#  parent_id       :integer
#
# Indexes
#
#  index_madmp_fragments_on_answer_id        (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)
#
# Foreign Keys
#
#  fk_rails_...  (answer_id => answers.id)
#  fk_rails_...  (madmp_schema_id => madmp_schemas.id)
#

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
  # DataSharing STI model
  class DataSharing < MadmpFragment
    def distribution
      Fragment::Distribution.where(parent_id: id)
    end

    def indexed_in
      Fragment::TechnicalResource.where(parent_id: id).first
    end

    def host
      Fragment::Host.where(parent_id: id).first
    end

    def contributors
      Fragment::Contributor.where(parent_id: id)
    end

    def cost
      Fragment::Cost.where(parent_id: id)
    end

    def properties
      'distribution, indexed_in, host, contributors, cost'
    end

    def self.sti_name
      'data_sharing'
    end
  end
end
