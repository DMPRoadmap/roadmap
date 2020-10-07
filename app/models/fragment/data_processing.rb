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


class Fragment::DataProcessing < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def processing
		Fragment::TechnicalResourceUsage.where(parent_id: id).first
	end

	def contributors
		Fragment::Contributor.where(parent_id: id)
	end

	def cost
		Fragment::Cost.where(parent_id: id)
	end

	def properties
		"plan, processing, contributors, cost"
	end

	# Cited as dataProcessing

	def used_in
		"research_output"
	end

	def self.sti.name
		"data_processing"
	end

end