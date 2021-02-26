module DynamicFormHelper

  def create_text_field(form, value, name, label, field_id, required: false, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil, example: nil, default_value: nil)
    render partial: "shared/dynamic_form/fields/text_field",
    locals: {
      f: form,
      multiple: is_multiple,
      index: index,
      field_value: value,
      field_name: name,
      field_label: label,
      field_class: html_class,
      field_id: field_id,
      input_type: nil,
      readonly: readonly,
      required: required,
      validation: validation,
      ttip: ttip,
      example: example,
      default_value: default_value
    }
  end

  def create_textarea_field(form, value, name, label, field_id, required: false, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil, example: nil, default_value: nil)
    render partial: "shared/dynamic_form/fields/textarea_field",
    locals: {
      f: form,
      multiple: is_multiple,
      index: index,
      field_value: value,
      field_name: name,
      field_label: label,
      field_class: html_class,
      field_id: field_id,
      input_type: nil,
      readonly: readonly,
      required: required,
      validation: validation,
      ttip: ttip,
      example: example,
      default_value: default_value
    }
  end

  def create_url_field(form, value, name, label, field_id, required: false, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil, example: nil, default_value: nil)
    render partial: "shared/dynamic_form/fields/text_field",
    locals: {
      f: form,
      multiple: is_multiple,
      index: index,
      field_value: value,
      field_name: name,
      field_label: label,
      field_class: html_class,
      field_id: field_id,
      input_type: "url",
      readonly: readonly,
      required: required,
      validation: validation,
      ttip: ttip,
      example: example,
      default_value: default_value
    }
  end

  def create_email_field(form, value, name, label, field_id, required: false, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil, example: nil, default_value: nil)
    render partial: "shared/dynamic_form/fields/text_field",
    locals: {
      f: form,
      multiple: is_multiple,
      index: index,
      field_value: value,
      field_name: name,
      field_label: label,
      field_class: html_class,
      field_id: field_id,
      input_type: "email",
      readonly: readonly,
      required: required,
      validation: validation,
      ttip: ttip,
      example: example,
      default_value: default_value
    }
  end

  def create_date_field(form, value, name, label, field_id, required: false, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil, example: nil, default_value: nil)
    render partial: "shared/dynamic_form/fields/text_field",
    locals: {
      f: form,
      multiple: is_multiple,
      index: index,
      field_value: value,
      field_name: name,
      field_label: label,
      field_class: html_class,
      field_id: field_id,
      input_type: "date",
      readonly: readonly,
      required: required,
      validation: validation,
      ttip: ttip,
      example: example,
      default_value: default_value
    }
  end

  def create_number_field(form, value, name, label, field_id, required: false, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil)
    render partial: "shared/dynamic_form/fields/number_field",
    locals: {
      f: form,
      multiple: is_multiple,
      index: index,
      field_value: value,
      field_name: name,
      field_label: label,
      field_class: html_class,
      field_id: field_id,
      readonly: readonly,
      required: required,
      validation: validation,
      ttip: ttip
    }
  end

  def create_checkbox_field(form, value, name, label, field_id, validation: nil, readonly: false)
    render partial: "shared/dynamic_form/fields/checkbox_field",
    locals: {
      f: form,
      field_value: value,
      field_name: name,
      field_label: label,
      field_id: field_id,
      readonly: readonly,
      validation: validation
    }
  end

  def create_select_field(form, value, name, label, field_id, select_values, locale, required: false, validation: nil, html_class: nil, readonly: false, multiple: false, ttip: nil, default_value: nil)
    render partial: "shared/dynamic_form/fields/select_field",
    locals: {
      f: form,
      selected_value: value,
      field_name: name,
      field_label: label,
      select_values: select_values,
      locale: locale,
      field_class: html_class,
      field_id: field_id,
      multiple: multiple,
      readonly: readonly,
      required: required,
      validation: validation,
      ttip: ttip,
      default_value: default_value
    }
  end

  def display_validation_message(validations)
    message = ""
    validations.each do |validation|
      case validation
      when "required"
        message += d_("dmpopidor", "This property is required.")
      when "pattern"
        message += d_("dmpopidor", "This property has an invalid format.")
      else
        message += d_("dmpopidor", "This property has an unknown problem : %{validation}") % {
          validation: validation
        }
      end
    end
    message
  end

  # Generate a select option "value" depending on the type of registry value
  # if it as a "complex" value, returns the id of the registry value
  # else returns the value (simple enum are save as String most of the time)
  def select_value(registry_value, locale)
    if registry_value.data["label"].present?
      registry_value.id
    else
      registry_value.to_s(locale)
    end
  end

  # Formats the data extract from the structured answer form to valid JSON data
  # This is useful because Rails converts all form data to strings and JSON needs the actual types
  def data_reformater(schema, data)
    schema["properties"].each do |key, prop|
      next if data[key].nil?

      if data[key] == ""
        data[key] = nil
      else
        case prop["type"]
        when "integer", "number"
          data[key] = data[key].to_i
        when "boolean"
          data[key] = data[key] == "1"
        when "array"
          data[key] = data[key].is_a?(Array) ? data[key] : [data[key]]
        when "object"
          next if prop["schema_id"].nil?

          sub_schema = MadmpSchema.find(prop["schema_id"])

          if prop["inputType"].present? && prop["inputType"].eql?("pickOrCreate")
            data[key] = { "dbid" => data[key].to_i }
          elsif prop["registry_id"].present?
            data[key] = data_reformater(
              sub_schema.schema,
              RegistryValue.find(data[key].to_i).data.merge(
                "id": data[key].to_i
              )
            )
          else
            data[key] = data_reformater(
              sub_schema.schema,
              data[key]
            )
          end
        else
          data[key] = data[key]
        end

      end
    end
    data
  end

end
