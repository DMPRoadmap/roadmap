# frozen_string_literal: true

module CodebaseFragment

  def save_codebase_fragment(codebase_data, schema)
    fragmented_data = {}
    codebase_data.each do |prop, content|
      schema_prop = schema.schema["properties"][prop]

      next if schema_prop.nil? || schema_prop["type"].nil?

      if schema_prop["type"].eql?("object") &&
         schema_prop["schema_id"].present?
        ####################################
        # OBJECT FIELDS
        ####################################
        sub_data = content # TMP: for readability
        next if content["action"].nil?

        sub_schema = MadmpSchema.find(schema_prop["schema_id"])

        if sub_data["action"].eql?("create")
          cb_fragment = MadmpFragment.new(
            dmp_id: dmp.id,
            parent_id: id,
            madmp_schema_id: sub_schema.id,
            additional_info: { property_name: prop }
          )
          cb_fragment.classname = sub_schema.classname
          cb_fragment.instantiate
          cb_fragment.save_codebase_fragment(sub_data["data"], sub_schema)
        elsif sub_data["action"].eql?("update") && sub_data["dbid"]
          cb_fragment = MadmpFragment.find(sub_data["dbid"])
          cb_fragment.save_codebase_fragment(sub_data["data"], sub_schema)
        end
      elsif schema_prop["type"].eql?("array") &&
            schema_prop["items"]["schema_id"].present?
        ####################################
        # ARRAY FIELDS
        ####################################
        data_list = content # TMP: for readability
        data_list.each do |cb_data|
          next if cb_data["action"].nil?

          sub_schema = MadmpSchema.find(schema_prop["items"]["schema_id"])

          if cb_data["action"].eql?("create")
            cb_fragment = MadmpFragment.new(
              dmp_id: dmp.id,
              parent_id: id,
              madmp_schema_id: sub_schema.id,
              additional_info: { property_name: prop }
            )
            cb_fragment.classname = sub_schema.classname
            cb_fragment.instantiate
            cb_fragment.save_codebase_fragment(cb_data["data"], sub_schema)
          elsif cb_data["action"].eql?("update") && cb_data["dbid"]
            cb_fragment = MadmpFragment.find(cb_data["dbid"])
            cb_fragment.save_codebase_fragment(cb_data["data"], sub_schema)
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
  end

end
