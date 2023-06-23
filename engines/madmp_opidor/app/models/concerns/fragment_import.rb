# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength
# Module containing different ways of importing a fragment
module FragmentImport
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def raw_import(import_data, schema, parent_id = id)
    return if import_data.nil?

    fragmented_data = {}

    # rubocop:disable Metrics/BlockLength
    import_data.each do |prop, content|
      next if content.nil?

      schema_prop = schema.schema['properties'][prop]
      fragmented_data = import_data if prop.eql?('custom_value')
      next if schema_prop&.dig('type').nil?

      if schema_prop['type'].eql?('object') &&
         schema_prop['schema_id'].present?
        sub_data = content # TMP: for readability
        sub_schema = MadmpSchema.find(schema_prop['schema_id'])
        # For persons, we need to check if the person exists and set manually
        # the dbid in the parent fragment
        if schema_prop['inputType'].eql?('pickOrCreate')
          sub_fragment = MadmpFragment.fragment_exists?(sub_data, sub_schema, dmp.id, parent_id)
          if sub_fragment.eql?(false)
            sub_fragment = MadmpFragment.new(
              data: sub_data,
              dmp_id: dmp.id,
              parent_id:,
              madmp_schema_id: sub_schema.id,
              additional_info: { property_name: prop }
            )
            sub_fragment.classname = sub_schema.classname
            sub_fragment.save!
          else
            sub_fragment.raw_import(sub_data, sub_schema, sub_fragment.id)
          end
          # If sub_data is a Person, we need to set the dbid manually, since Person has no parent
          # and update_references function is not triggered

          fragmented_data[prop] = { 'dbid' => sub_fragment.id }
          next
        end
        if data[prop].nil?
          sub_fragment = MadmpFragment.new(
            dmp_id: dmp.id,
            parent_id:,
            madmp_schema_id: sub_schema.id,
            additional_info: { property_name: prop }
          )
          sub_fragment.classname = sub_schema.classname
          sub_fragment.instantiate
        else
          sub_fragment = MadmpFragment.find(data[prop]['dbid'])
        end

        sub_fragment.raw_import(sub_data, sub_schema, sub_fragment.id)

      elsif schema_prop['type'].eql?('array') &&
            schema_prop['items']['schema_id'].present?
        ####################################
        # ARRAY FIELDS
        ####################################
        # Seems like sending empty arrays through the API set them as nil so we need to initialize them
        fragment_list = content || []
        fragment_list = [fragment_list] unless fragment_list.is_a?(Array)

        fragment_list.each do |sub_fragment_data|
          sub_schema = MadmpSchema.find(schema_prop['items']['schema_id'])
          sub_fragment = MadmpFragment.fragment_exists?(sub_fragment_data, sub_schema, dmp.id, parent_id)
          if sub_fragment.eql?(false)
            sub_fragment = MadmpFragment.new(
              dmp_id: dmp.id,
              parent_id:,
              madmp_schema_id: sub_schema.id,
              additional_info: { property_name: prop }
            )
            sub_fragment.classname = sub_schema.classname
            sub_fragment.instantiate

          end
          sub_fragment.raw_import(sub_fragment_data, sub_schema, sub_fragment.id)
        end
      else
        fragmented_data[prop] = content
      end
    end
    # rubocop:enable Metrics/BlockLength

    fragmented_data.try(:permit!)
    update!(
      data: data.merge(fragmented_data),
      additional_info: additional_info.except!('custom_value')
    )

    update_children_references
    self # return self
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def import_with_ids(import_data, schema)
    fragmented_data = {}

    # rubocop:disable Metrics/BlockLength
    import_data.each do |prop, content|
      schema_prop = schema.properties[prop]

      next if schema_prop&.dig('type').nil?

      if schema_prop['type'].eql?('object') &&
         schema_prop['schema_id'].present?
        sub_data = content # TMP: for readability
        sub_schema = MadmpSchema.find(schema_prop['schema_id'])

        if content['id'].present?
          api_fragment = MadmpFragment.find(sub_data['id'])
          api_fragment.import_with_ids(sub_data, sub_schema)
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
          #   created_frag = api_fragment.import_with_ids(sub_data, sub_schema)
          #   # If sub_data is a Person, we need to set the dbid manually, since Person has no parent
          #   # and update_references function is not triggered
          #   fragmented_data[prop] = { 'dbid' => created_frag.id } if sub_schema.classname.eql?('person')
        end
      elsif schema_prop['type'].eql?('array') &&
            schema_prop['items']['schema_id'].present?
        ####################################
        # ARRAY FIELDS
        ####################################
        # Seems like sending empty arrays through the API set them as nil so we need to initialize them
        fragment_list = content || []
        fragment_list.each do |sub_fragment_data|
          sub_schema = MadmpSchema.find(schema_prop['items']['schema_id'])

          if sub_fragment_data['id'].present?
            api_fragment = MadmpFragment.find(sub_fragment_data['id'])
            api_fragment.import_with_instructions(sub_fragment_data, sub_schema)
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
            api_fragment.import_with_ids(sub_fragment_data, sub_schema)
          end
        end
      else
        fragmented_data[prop] = content
      end
    end
    # rubocop:enable Metrics/BlockLength

    update!(
      data: data.merge(fragmented_data),
      additional_info: additional_info.except!('custom_value')
    )
    update_children_references
    self # return self
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def import_with_instructions(import_data, schema)
    fragmented_data = {}

    # rubocop:disable Metrics/BlockLength
    import_data.each do |prop, content|
      schema_prop = schema.properties[prop]

      next if schema_prop&.dig('type').nil?

      if schema_prop['type'].eql?('object') &&
         schema_prop['schema_id'].present?
        ####################################
        # OBJECT FIELDS
        ####################################
        sub_data = content # TMP: for readability
        next if content['action'].nil?

        sub_schema = MadmpSchema.find(schema_prop['schema_id'])

        if sub_data['action'].eql?('create')
          next if MadmpFragment.fragment_exists?(sub_data['data'], sub_schema, dmp.id, id)

          cb_fragment = MadmpFragment.new(
            dmp_id: dmp.id,
            parent_id: id,
            madmp_schema_id: sub_schema.id,
            additional_info: { property_name: prop }
          )
          cb_fragment.classname = sub_schema.classname
          cb_fragment.instantiate
          created_frag = cb_fragment.import_with_instructions(sub_data['data'], sub_schema)
          # If sub_data is a Person, we need to set the dbid manually, since Person has no parent
          # and update_references function is not triggered
          fragmented_data[prop] = { 'dbid' => created_frag.id } if sub_schema.classname.eql?('person')
        elsif sub_data['action'].eql?('update') && sub_data['dbid']
          cb_fragment = MadmpFragment.find(sub_data['dbid'])
          cb_fragment.import_with_instructions(sub_data['data'], sub_schema)
        end
      elsif schema_prop['type'].eql?('array') &&
            schema_prop['items']['schema_id'].present?
        ####################################
        # ARRAY FIELDS
        ####################################
        data_list = content # TMP: for readability
        data_list.each do |cb_data|
          next if cb_data['action'].nil?

          sub_schema = MadmpSchema.find(schema_prop['items']['schema_id'])

          if cb_data['action'].eql?('create')
            next if MadmpFragment.fragment_exists?(cb_data['data'], sub_schema, dmp.id, id)

            cb_fragment = MadmpFragment.new(
              dmp_id: dmp.id,
              parent_id: id,
              madmp_schema_id: sub_schema.id,
              additional_info: { property_name: prop }
            )
            cb_fragment.classname = sub_schema.classname
            cb_fragment.instantiate
            created_frag = cb_fragment.import_with_instructions(cb_data['data'], sub_schema)
          elsif cb_data['action'].eql?('update') && cb_data['dbid']
            cb_fragment = MadmpFragment.find(cb_data['dbid'])
            cb_fragment.import_with_instructions(cb_data['data'], sub_schema)
          end
        end
      else
        fragmented_data[prop] = content
      end
    end
    # rubocop:enable Metrics/BlockLength

    update!(
      data: data.merge(fragmented_data),
      additional_info: additional_info.except!('custom_value')
    )
    update_children_references
    self # return self
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
# rubocop:enable Metrics/ModuleLength
