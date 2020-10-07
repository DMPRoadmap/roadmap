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


class Fragment::License < MadmpFragment

	def plan
		Plan.find(data["plan_id"])
	end

	def properties
		"plan"
	end

	# Cited as license

	def used_in
		"distribution, meta, reused_data"
	end

	def self.sti.name
		"license"
	end

end