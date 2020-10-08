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


class Fragment::Cost < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def cost_value
		Fragment::CostValue.where(parent_id: id).first
	end

	def properties
		"plan, cost_value"
	end

	# Cited as cost

	def used_in
		"budget_item, data_collection, data_preservation, data_processing, data_reuse, data_sharing, data_storage, documentation_quality, technical_resource_usage"
	end

	def self.sti_name
		"cost"
	end

end