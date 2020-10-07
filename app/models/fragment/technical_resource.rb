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


class Fragment::TechnicalResource < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def technical_resource_id
		Fragment::Identifier.where(parent_id: id).first
	end

	def properties
		"plan, technical_resource_id"
	end

	# Cited as indexedIn, facility

	def used_in
		"data_sharing, technical_resource_usage"
	end

	def self.sti.name
		"technical_resource"
	end

end