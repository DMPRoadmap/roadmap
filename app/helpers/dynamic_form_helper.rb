module DynamicFormHelper

  def create_text_field(form, value, name, label, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil, example: nil)
    render partial: 'shared/dynamic_form/fields/text_field', 
    locals: {
      f: form, 
      multiple: is_multiple,
      index: index,
      field_value: value, 
      field_name: name, 
      field_label: label,
      field_class: html_class,
      input_type: nil,
      readonly: readonly, 
      validation: validation,
      ttip: ttip,
      example: example
    }
  end



  def create_url_field(form, value, name, label, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil, example: nil)
    render partial: 'shared/dynamic_form/fields/text_field', 
    locals: {
      f: form, 
      multiple: is_multiple,
      index: index,
      field_value: value, 
      field_name: name, 
      field_label: label,
      field_class: html_class,
      input_type: 'url',
      readonly: readonly, 
      validation: validation,
      ttip: ttip,
      example: example
    }
  end
  
  
  
  def create_email_field(form, value, name, label, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil, example: nil)
    render partial: 'shared/dynamic_form/fields/text_field', 
    locals: {
      f: form, 
      multiple: is_multiple,
      index: index,
      field_value: value, 
      field_name: name, 
      field_label: label,
      field_class: html_class,
      input_type: 'email',
      readonly: readonly, 
      validation: validation,
      ttip: ttip,
      example: example
    }
  end



  def create_date_field(form, value, name, label, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil, example: nil)
    render partial: 'shared/dynamic_form/fields/text_field', 
    locals: {
      f: form, 
      multiple: is_multiple,
      index: index,
      field_value: value, 
      field_name: name, 
      field_label: label,
      field_class: html_class,
      input_type: 'date',
      readonly: readonly, 
      validation: validation,
      ttip: ttip,
      example: example
    }
  end



  def create_number_field(form, value, name, label, validation: nil, html_class: nil, is_multiple: false, readonly: false, index: 0, ttip: nil)
    render partial: 'shared/dynamic_form/fields/number_field', 
    locals: {
      f: form, 
      multiple: is_multiple,
      index: index,
      field_value: value, 
      field_name: name, 
      field_label: label,
      field_class: html_class,
      readonly: readonly, 
      validation: validation,
      ttip: ttip
    }
  end



  def create_checkbox_field(form, value, name, label, validation: nil, html_class: nil, readonly: false)
    render partial: 'shared/dynamic_form/fields/checkbox_field', 
    locals: {
      f: form, 
      field_value: value, 
      field_name: name, 
      field_label: label, 
      readonly: readonly, 
      validation: validation
    }
  end

  def create_select_field(form, value, name, label, select_values, validation: nil, html_class: nil, readonly: false, multiple: false, ttip: nil)
    render partial: 'shared/dynamic_form/fields/select_field', 
    locals: {
      f: form, 
      selected_value: value, 
      field_name: name,
      field_label: label,
      select_values: select_values,
      field_class: html_class,
      multiple: multiple,
      readonly: readonly, 
      validation: validation,
      ttip: ttip
    }
  end

  def display_validation_message(validations)
    message = ""
    validations.each do |validation|
      case validation
      when "required"
        message += d_('dmpopidor', 'This property is required.')
      when "pattern"
        message += d_('dmpopidor', 'This property has an invalid format.')
      else 
        message += d_('dmpopidor', 'This property has an unknown problem : %{validation}') % {
          validation: validation
        }
      end
    end
    message
  end

  # Formats the data extract from the structured answer form to valid JSON data
  # This is useful because Rails converts all form data to strings and JSON needs the actual types
  def data_reformater(schema, data, classname)
    schema["properties"].each do |key, prop|
      if data[key] == ""
        data.delete(key)
      else 
        case prop["type"]
        when "integer", "number"
          data[key] = data[key].to_i
        when "boolean"
          data[key] = data[key] == "1"
        when "array"
          data[key] = data[key].kind_of?(Array) ? data[key] : [data[key]]
        when "object"
          if prop['schema_id'].present? && classname != "research_output"
            sub_schema = MadmpSchema.find(prop['schema_id'])
            data[key] = data_reformater(sub_schema.schema, data[key], sub_schema.classname)
          end 
          # if value["dictionnary"]
          #   data[key] = JSON.parse(DictionnaryValue.where(id: data[key]).select(:id, :uri, :label).take.to_json)
          # end
        end
      end 
    end
    data
  end
  
end
