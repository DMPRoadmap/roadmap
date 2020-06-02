module DynamicFormHelper
  def create_dynamic_form(schema, form, data)
    schema["properties"].each do |key, prop|
      case prop["type"]
      when "string"
        create_text_field(form, data[key], key, prop["label"])
      when "integer"
        create_number_field(form, data[key], key, prop["label"])
      when "boolean"
        create_checkbox_field(form, data[key], key, prop["label"])
      when "array"
        render partial: 'questions/fields/multiple_field', 
        locals: {
          f: form, 
          field_values: @structured_datum.data[key], 
          field_properties: prop, 
          field_name: key
        }
      end
    end 
  end

  def create_text_field(form, value, name, label, html_class: nil, is_multiple: false, index: 0)
    render partial: 'shared/dynamic_form/fields/text_field', 
    locals: {
    f: form, 
    multiple: is_multiple,
    index: index,
    field_value: value, 
    field_name: name, 
    field_label: label,
    field_class: html_class,
    input_type: nil
  }
  end



  def create_url_field(form, value, name, label, html_class: nil, is_multiple: false, index: 0)
    render partial: 'shared/dynamic_form/fields/text_field', 
    locals: {
    f: form, 
    multiple: is_multiple,
    index: index,
    field_value: value, 
    field_name: name, 
    field_label: label,
    field_class: html_class,
    input_type: 'url'
  }
  end



  def create_email_field(form, value, name, label, html_class: nil, is_multiple: false, index: 0)
    render partial: 'shared/dynamic_form/fields/text_field', 
    locals: {
    f: form, 
    multiple: is_multiple,
    index: index,
    field_value: value, 
    field_name: name, 
    field_label: label,
    field_class: html_class,
    input_type: 'email'
  }
  end



  def create_date_field(form, value, name, label, html_class: nil, is_multiple: false, index: 0)
    render partial: 'shared/dynamic_form/fields/text_field', 
    locals: {
    f: form, 
    multiple: is_multiple,
    index: index,
    field_value: value, 
    field_name: name, 
    field_label: label,
    field_class: html_class,
    input_type: 'date'
  }
  end



  def create_number_field(form, value, name, label, html_class=nil, is_multiple=false, index=0)
    render partial: 'shared/dynamic_form/fields/number_field', 
    locals: {
    f: form, 
    multiple: is_multiple,
    index: index,
    field_value: value, 
    field_name: name, 
    field_label: label
  }
  end



  def create_checkbox_field(form, value, name, label, html_class: nil)
    render partial: 'shared/dynamic_form/fields/checkbox_field', 
    locals: {
    f: form, 
    field_value: value, 
    field_name: name, 
    field_label: label
  }
  end

  def create_select_field(form, value, name, properties, html_class: nil)
    render partial: 'questions/fields/select_field', 
    locals: {
    f: form, 
    field_value: value, 
    field_name: name, 
    field_properties: properties
  }
  end 

  def create_schema_field(form, value, name, label, is_multiple=false, index=0, schema_id, answer_id)
    render partial: 'questions/fields/schema_field', 
    locals: {
    f: form, 
    multiple: is_multiple,
    index: index,
    field_value: value, 
    field_name: name, 
    field_label: label,
    schema_id: schema_id,
    answer_id: answer_id,
  }
  end

end
