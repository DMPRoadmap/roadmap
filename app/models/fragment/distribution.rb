# == Schema Information
#
# Table name: madmp_fragments
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
#
# Indexes
#
#  index_madmp_fragments_on_answer_id                  (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)
#

class Fragment::Distribution < MadmpFragment

    def research_output
        self.parent
    end

    
    def self.sti_name
        "distribution"
    end
end
