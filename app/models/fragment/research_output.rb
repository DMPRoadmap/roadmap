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


class Fragment::ResearchOutput < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def research_output_description
		Fragment::ResearchOutputDescription.where(parent_id: id).first
	end

	def reuse
		Fragment::DataReuse.where(parent_id: id).first
	end

	def personal_data_issues
		Fragment::PersonalDataIssues.where(parent_id: id).first
	end

	def legal_issues
		Fragment::LegalIssues.where(parent_id: id).first
	end

	def ethical_issues
		Fragment::EthicalIssues.where(parent_id: id).first
	end

	def data_collection
		Fragment::DataCollection.where(parent_id: id).first
	end

	def data_processing
		Fragment::DataProcessing.where(parent_id: id).first
	end

	def data_storage
		Fragment::DataStorage.where(parent_id: id).first
	end

	def documentation_quality
		Fragment::DocumentationQuality.where(parent_id: id).first
	end

	def sharing
		Fragment::DataSharing.where(parent_id: id).first
	end

	def preservation_issues
		Fragment::DataPreservation.where(parent_id: id).first
	end

	def budget
		Fragment::Budget.where(parent_id: id).first
	end

	def properties
		"plan, research_output_description, reuse, personal_data_issues, legal_issues, ethical_issues, data_collection, data_processing, data_storage, documentation_quality, sharing, preservation_issues, budget"
	end

	# Cited as researchOutput

	def used_in
		"dmp"
	end

	def self.sti.name
		"research_output"
	end

end