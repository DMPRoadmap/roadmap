# frozen_string_literal: true

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

  def create_textarea_field(form, value, name, label, field_id, required: false, validation: nil, html_class: nil, readonly: false, index: 0, ttip: nil, example: nil, default_value: nil)
    render partial: "shared/dynamic_form/fields/textarea_field",
    locals: {
      f: form,
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

  def create_number_field(form, value, name, label, field_id, minimum, maximum, required: false, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil)
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
      minimum: minimum,
      maximum: maximum,
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

  def create_simple_registry_field(form, value, form_prefix, property_name, label, field_id, select_values, locale, required: false, validation: nil, html_class: nil, readonly: false, multiple: false, ttip: nil, default_value: nil, overridable: nil)
    partial_name = if multiple
                     "shared/dynamic_form/fields/registry/multiple"
                   else
                     "shared/dynamic_form/fields/registry/simple"
                   end
    render partial: partial_name,
    locals: {
      f: form,
      selected_value: value,
      form_prefix: form_prefix,
      property_name: property_name,
      field_label: label,
      select_values: select_values,
      locale: locale,
      field_class: html_class,
      field_id: field_id,
      readonly: readonly,
      required: required,
      validation: validation,
      ttip: ttip,
      default_value: default_value,
      overridable: overridable
    }
  end

  def create_single_complex_registry_field(form, value, form_prefix, property_name, label, field_id, select_values, locale, parent_id, schema_id, required: false, validation: nil, html_class: nil, readonly: false, ttip: nil, default_value: nil, overridable: nil)
    render partial: "shared/dynamic_form/fields/registry/single_complex",
    locals: {
      f: form,
      value: value,
      form_prefix: form_prefix,
      property_name: property_name,
      field_label: label,
      select_values: select_values,
      locale: locale,
      parent_id: parent_id,
      schema_id: schema_id,
      field_class: html_class,
      field_id: field_id,
      readonly: readonly,
      required: required,
      validation: validation,
      ttip: ttip,
      default_value: default_value,
      overridable: overridable
    }
  end

  def create_multiple_complex_registry_field(form, value, form_prefix, property_name, label, field_id, select_values, locale, parent_id, schema_id, required: false, validation: nil, html_class: nil, readonly: false, ttip: nil, default_value: nil, overridable: nil)
    render partial: "shared/dynamic_form/fields/registry/multiple_complex",
    locals: {
      f: form,
      value: value,
      form_prefix: form_prefix,
      property_name: property_name,
      field_label: label,
      select_values: select_values,
      locale: locale,
      parent_id: parent_id,
      schema_id: schema_id,
      field_class: html_class,
      field_id: field_id,
      readonly: readonly,
      required: required,
      validation: validation,
      ttip: ttip,
      default_value: default_value,
      overridable: overridable
    }
  end

  def create_hidden_field(form, value, name)
    render partial: "shared/dynamic_form/fields/const_field",
    locals: {
      f: form,
      field_value: value,
      field_name: name,
      field_label: nil,
      is_const_field: false
    }
  end

  def create_const_field(form, value, name, label)
    render partial: "shared/dynamic_form/fields/const_field",
    locals: {
      f: form,
      field_value: value,
      field_name: name,
      field_label: label,
      is_const_field: true
    }
  end

  def display_validation_message(validations)
    message = ""
    validations.each do |validation|
      case validation
      when "required"
        message += _("This property is required.")
      when "pattern"
        message += _("This property has an invalid format.")
      else
        message += _("This property has an unknown problem : %{validation}") % {
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
    if registry_value.data["value"].present?
      registry_value.data["value"][locale] || registry_value.data["value"]
    elsif registry_value.data["label"].present?
      registry_value.id
    else
      registry_value.data[locale] || registry_value.data
    end
  end

  def form_label(property, locale, readonly)
    if readonly
      property["label@#{locale}"]
    else
      property["form_label@#{locale}"] || property["label@#{locale}"]
    end
  end

  # Formats the data extract from the structured answer form to valid JSON data
  # This is useful because Rails converts all form data to strings and JSON needs the actual types
  def data_reformater(schema, data)
    formated_data = {}
    schema.properties.each do |key, prop|
      next if data[key].nil? || key.end_with?("_custom")

      case prop["type"]
      when "integer", "number"
        formated_data[key] = data[key].tr(" ", "").to_i
      when "boolean"
        formated_data[key] = data[key] == "1"
      when "array"
        formated_data[key] = data[key].is_a?(Array) ? data[key].reject(&:empty?) : [data[key]].reject(&:empty?)
      when "object"
        next if prop["schema_id"].nil?

        sub_schema = MadmpSchema.find(prop["schema_id"])

        if prop["inputType"].eql?("pickOrCreate")
          formated_data[key] = { "dbid" => data[key].to_i }
        elsif prop["registry_id"].present?
          # if the field is overridable, check if there's a custom value
          if prop["overridable"].present? && data["#{key}_custom"].present?
            formated_data[key] = { "custom_value" => data["#{key}_custom"] }
            next
          end

          formated_data[key] = if data[key].present?
                                 data_reformater(
                                   sub_schema,
                                   RegistryValue.find(data[key].to_i).data.merge(
                                     "id": data[key].to_i
                                   )
                                 )
                               end
        else
          formated_data[key] = data_reformater(
            sub_schema,
            data[key]
          )
        end
      else # type = string
        # if the field is overridable, check if there's a custom value
        if prop["overridable"].present? && data["#{key}_custom"].present?
          formated_data[key] = if data["#{key}_custom"].eql?("__DELETED__")
                                 ""
                               else
                                 ActionController::Base.helpers.sanitize(
                                   data["#{key}_custom"],
                                   { scrubber: DynamicFormScrubber.new }
                                 )
                               end
        else
          formated_data[key] = ActionController::Base.helpers.sanitize(
            data[key],
            { scrubber: DynamicFormScrubber.new }
          )
        end
      end

      formated_data[key] = nil if formated_data[key].eql?("")
    end
    formated_data
  end

  def display_identifier(identifier, identifier_type, with_parenthesis = false)
    return nil if identifier.nil?

    if with_parenthesis
      "(#{identifier_type}:#{identifier})"
    else
      "#{identifier_type}:#{identifier}"
    end
  end

end
