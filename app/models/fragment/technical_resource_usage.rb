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


class Fragment::TechnicalResourceUsage < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def facility
		Fragment::TechnicalResource.where(parent_id: id).first
	end

	def backup_policy
		Fragment::BackupPolicy.where(parent_id: id).first
	end

	def contact
		Fragment::Contributor.where(parent_id: id).first
	end

	def cost
		Fragment::Cost.where(parent_id: id)
	end

	def specific_data
		Fragment::SpecificData.where(parent_id: id).first
	end

	def properties
		"plan, facility, backup_policy, contact, cost, specific_data"
	end

	# Cited as acquisition, preservation, processing, hosting, storage

	def used_in
		"data_collection, data_preservation, data_processing, data_sharing, data_storage"
	end

	def self.sti.name
		"technical_resource_usage"
	end

end