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

# WARNING !! : si changement de cardinalité de project, maintenance à prévoir dans les scripts appelants
module Fragment
  # Dmp STI model
  class Dmp < MadmpFragment
    def plan
      Plan.find(data['plan_id'])
    end

    def meta
      Fragment::Meta.where(parent_id: id).first
    end

    def project
      Fragment::Project.where(parent_id: id).first
    end

    def research_entity
      Fragment::ResearchEntity.where(parent_id: id).first
    end

    def research_outputs
      Fragment::ResearchOutput.where(parent_id: id)
    end

    def budget
      Fragment::Budget.where(parent_id: id).first
    end

    def properties
      'plan, meta, project, research_output'
    end

    def contributors
      Fragment::Person.where(dmp_id: id)
    end

    def costs
      Fragment::Cost.where(dmp_id: id)
    end

    def persons
      Fragment::Person.where(dmp_id: id)
    end

    def locale
      meta.data['dmpLanguage']
    end

    def dmp
      self
    end

    def self.sti_name
      'dmp'
    end
  end
end
