module DynamicFormHelper

  def create_text_field(form, value, name, label, html_class: nil, is_multiple: false, readonly: false, index: 0)
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
      readonly: readonly
    }
  end



  def create_url_field(form, value, name, label, html_class: nil, is_multiple: false, readonly: false, index: 0)
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
      readonly: readonly
    }
  end



  def create_email_field(form, value, name, label, html_class: nil, is_multiple: false, readonly: false, index: 0)
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
      readonly: readonly
    }
  end



  def create_date_field(form, value, name, label, html_class: nil, is_multiple: false, readonly: false, index: 0)
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
      readonly: readonly
    }
  end



  def create_number_field(form, value, name, label, html_class: nil, is_multiple: false, readonly: false, index: 0)
    render partial: 'shared/dynamic_form/fields/number_field', 
    locals: {
      f: form, 
      multiple: is_multiple,
      index: index,
      field_value: value, 
      field_name: name, 
      field_label: label,
      field_class: html_class,
      readonly: readonly
    }
  end



  def create_checkbox_field(form, value, name, label, html_class: nil, readonly: false)
    render partial: 'shared/dynamic_form/fields/checkbox_field', 
    locals: {
      f: form, 
      field_value: value, 
      field_name: name, 
      field_label: label, 
      readonly: readonly
    }
  end

  def create_select_field(form, value, name, label, select_values, html_class: nil, readonly: false)
    render partial: 'shared/dynamic_form/fields/select_field', 
    locals: {
      f: form, 
      selected_value: value, 
      field_name: name,
      field_label: label,
      select_values: select_values,
      field_class: html_class,
      readonly: readonly
    }
  end 


  # Formats the data extract from the structured answer form to valid JSON data
  # This is useful because Rails converts all form data to strings and JSON needs the actual types
  def data_reformater(schema, data)
    schema["properties"].each do |key, prop|
      case prop["type"]
      when "integer"
        data[key] = data[key].to_i
      when "boolean"
        data[key] = data[key] == "1"
      when "array"
        data[key] = data[key].kind_of?(Array) ? data[key] : [data[key]]
      when "object"
        if prop['schema_id'].present?
          sub_schema = MadmpSchema.find(prop['schema_id'])
          data[key] = data_reformater(sub_schema.schema, data[sub_schema.classname])
        end 
        # if value["dictionnary"]
        #   data[key] = JSON.parse(DictionnaryValue.where(id: data[key]).select(:id, :uri, :label).take.to_json)
        # end
      end
    end
    data
  end
  
end
