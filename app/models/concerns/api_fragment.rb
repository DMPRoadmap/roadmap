# frozen_string_literal: true

module ApiFragment

  def save_api_fragment(api_data, schema)
    fragmented_data = {}

    api_data.each do |prop, content|
      schema_prop = schema.schema["properties"][prop]

      next if schema_prop&.dig("type").nil?

      if schema_prop["type"].eql?("object") &&
         schema_prop["schema_id"].present?
        sub_data = content # TMP: for readability
        sub_schema = MadmpSchema.find(schema_prop["schema_id"])

        if content["id"].present?
          api_fragment = MadmpFragment.find(sub_data["id"])
          api_fragment.save_api_fragment(sub_data, sub_schema)
        # else
        #   next if MadmpFragment.fragment_exists?(sub_data, sub_schema, dmp.id, id)

        #   api_fragment = MadmpFragment.new(
        #     dmp_id: dmp.id,
        #     parent_id: id,
        #     madmp_schema_id: sub_schema.id,
        #     additional_info: { property_name: prop }
        #   )
        #   api_fragment.classname = sub_schema.classname
        #   api_fragment.instantiate
        #   created_frag = api_fragment.save_api_fragment(sub_data, sub_schema)
        #   # If sub_data is a Person, we need to set the dbid manually, since Person has no parent
        #   # and update_references function is not triggered
        #   fragmented_data[prop] = { "dbid" => created_frag.id } if sub_schema.classname.eql?("person")
        end
      elsif schema_prop["type"].eql?("array") &&
            schema_prop["items"]["schema_id"].present?
        ####################################
        # ARRAY FIELDS
        ####################################
        # Seems like sending empty arrays through the API set them as nil so we need to initialize them 
        fragment_list = content || []
        fragment_list.each do |sub_fragment_data|
          sub_schema = MadmpSchema.find(schema_prop["items"]["schema_id"])

          if sub_fragment_data["id"].present?
            api_fragment = MadmpFragment.find(sub_fragment_data["id"])
            api_fragment.save_codebase_fragment(sub_fragment_data, sub_schema)
          else
            next if MadmpFragment.fragment_exists?(sub_fragment_data, sub_schema, dmp.id, id)

            api_fragment = MadmpFragment.new(
              dmp_id: dmp.id,
              parent_id: id,
              madmp_schema_id: sub_schema.id,
              additional_info: { property_name: prop }
            )
            api_fragment.classname = sub_schema.classname
            api_fragment.instantiate
            created_frag = api_fragment.save_api_fragment(sub_fragment_data, sub_schema)
          end
        end
      else
        fragmented_data[prop] = content
      end
    end
    update!(
      data: data.merge(fragmented_data),
      additional_info: additional_info.except!("custom_value")
    )
    update_children_references
    self # return self
  end

end
