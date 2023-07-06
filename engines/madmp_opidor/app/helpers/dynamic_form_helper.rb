# frozen_string_literal: true

# Module that provides helper methods for displaying a dynamic form
# rubocop:disable Metrics/ModuleLength
module DynamicFormHelper
  # rubocop:disable  Metrics/ParameterLists
  def create_text_field(form,
                        value,
                        name,
                        label,
                        field_id,
                        required: false,
                        validation: nil,
                        html_class: nil,
                        is_multiple: false,
                        readonly: false,
                        index: 0,
                        ttip: nil,
                        example: nil,
                        default_value: nil)
    render partial: 'dynamic_form/fields/text_field',
           locals: {
             f: form,
             multiple: is_multiple,
             index:,
             field_value: value,
             field_name: name,
             field_label: label,
             field_class: html_class,
             field_id:,
             input_type: nil,
             readonly:,
             required:,
             validation:,
             ttip:,
             example:,
             default_value:
           }
  end
  # rubocop:enable  Metrics/ParameterLists

  # rubocop:disable  Metrics/ParameterLists
  def create_textarea_field(form,
                            value,
                            name,
                            label,
                            field_id,
                            required: false,
                            validation: nil,
                            html_class: nil,
                            readonly: false,
                            index: 0,
                            ttip: nil,
                            example: nil,
                            default_value: nil)
    render partial: 'dynamic_form/fields/textarea_field',
           locals: {
             f: form,
             index:,
             field_value: value,
             field_name: name,
             field_label: label,
             field_class: html_class,
             field_id:,
             input_type: nil,
             readonly:,
             required:,
             validation:,
             ttip:,
             example:,
             default_value:
           }
  end
  # rubocop:enable  Metrics/ParameterLists

  # rubocop:disable  Metrics/ParameterLists
  def create_url_field(form,
                       value,
                       name,
                       label,
                       field_id,
                       required: false,
                       validation: nil,
                       html_class: nil,
                       is_multiple: false,
                       readonly: false,
                       index: 0,
                       ttip: nil,
                       example: nil,
                       default_value: nil)
    render partial: 'dynamic_form/fields/text_field',
           locals: {
             f: form,
             multiple: is_multiple,
             index:,
             field_value: value,
             field_name: name,
             field_label: label,
             field_class: html_class,
             field_id:,
             input_type: 'url',
             readonly:,
             required:,
             validation:,
             ttip:,
             example:,
             default_value:
           }
  end
  # rubocop:enable  Metrics/ParameterLists

  # rubocop:disable  Metrics/ParameterLists
  def create_email_field(form,
                         value,
                         name,
                         label,
                         field_id,
                         required: false,
                         validation: nil,
                         html_class: nil,
                         is_multiple: false,
                         readonly: false,
                         index: 0,
                         ttip: nil,
                         example: nil,
                         default_value: nil)
    render partial: 'dynamic_form/fields/text_field',
           locals: {
             f: form,
             multiple: is_multiple,
             index:,
             field_value: value,
             field_name: name,
             field_label: label,
             field_class: html_class,
             field_id:,
             input_type: 'email',
             readonly:,
             required:,
             validation:,
             ttip:,
             example:,
             default_value:
           }
  end
  # rubocop:enable  Metrics/ParameterLists

  # rubocop:disable  Metrics/ParameterLists
  def create_date_field(form,
                        value,
                        name,
                        label,
                        field_id,
                        required: false,
                        validation: nil,
                        html_class: nil,
                        is_multiple: false,
                        readonly: false,
                        index: 0,
                        ttip: nil,
                        example: nil,
                        default_value: nil)
    render partial: 'dynamic_form/fields/text_field',
           locals: {
             f: form,
             multiple: is_multiple,
             index:,
             field_value: value,
             field_name: name,
             field_label: label,
             field_class: html_class,
             field_id:,
             input_type: 'date',
             readonly:,
             required:,
             validation:,
             ttip:,
             example:,
             default_value:
           }
  end
  # rubocop:enable  Metrics/ParameterLists

  # rubocop:disable  Metrics/ParameterLists
  def create_number_field(form,
                          value,
                          name,
                          label,
                          field_id,
                          minimum,
                          maximum,
                          required: false,
                          validation: nil,
                          html_class: nil,
                          is_multiple: false,
                          readonly: false,
                          index: 0,
                          ttip: nil)
    render partial: 'dynamic_form/fields/number_field',
           locals: {
             f: form,
             multiple: is_multiple,
             index:,
             field_value: value,
             field_name: name,
             field_label: label,
             field_class: html_class,
             field_id:,
             minimum:,
             maximum:,
             readonly:,
             required:,
             validation:,
             ttip:
           }
  end
  # rubocop:enable  Metrics/ParameterLists

  # rubocop:disable  Metrics/ParameterLists
  def create_checkbox_field(form, value, name, label, field_id, validation: nil, readonly: false)
    render partial: 'dynamic_form/fields/checkbox_field',
           locals: {
             f: form,
             field_value: value,
             field_name: name,
             field_label: label,
             field_id:,
             readonly:,
             validation:
           }
  end
  # rubocop:enable  Metrics/ParameterLists

  # rubocop:disable  Metrics/ParameterLists, Metrics/MethodLength
  def create_simple_registry_field(form,
                                   value,
                                   form_prefix,
                                   property_name,
                                   label,
                                   field_id,
                                   select_values,
                                   locale,
                                   required: false,
                                   validation: nil,
                                   html_class: nil,
                                   readonly: false,
                                   multiple: false,
                                   ttip: nil,
                                   default_value: nil,
                                   overridable: nil)
    partial_name = if multiple
                     'dynamic_form/fields/registry/multiple'
                   else
                     'dynamic_form/fields/registry/simple'
                   end
    render partial: partial_name,
           locals: {
             f: form,
             selected_value: value,
             form_prefix:,
             property_name:,
             field_label: label,
             select_values:,
             locale:,
             field_class: html_class,
             field_id:,
             readonly:,
             required:,
             validation:,
             ttip:,
             default_value:,
             overridable:
           }
  end
  # rubocop:enable  Metrics/ParameterLists, Metrics/MethodLength

  # rubocop:disable  Metrics/ParameterLists
  def create_single_complex_registry_field(form,
                                           value,
                                           form_prefix,
                                           property_name,
                                           label,
                                           field_id,
                                           select_values,
                                           locale,
                                           parent_id,
                                           schema_id,
                                           required: false,
                                           validation: nil,
                                           html_class: nil,
                                           readonly: false,
                                           ttip: nil,
                                           default_value: nil,
                                           overridable: nil)
    render partial: 'dynamic_form/fields/registry/single_complex',
           locals: {
             f: form,
             value:,
             form_prefix:,
             property_name:,
             field_label: label,
             select_values:,
             locale:,
             parent_id:,
             schema_id:,
             field_class: html_class,
             field_id:,
             readonly:,
             required:,
             validation:,
             ttip:,
             default_value:,
             overridable:
           }
  end
  # rubocop:enable  Metrics/ParameterLists

  # rubocop:disable  Metrics/ParameterLists
  def create_multiple_complex_registry_field(form,
                                             value,
                                             form_prefix,
                                             property_name,
                                             label,
                                             field_id,
                                             select_values,
                                             locale,
                                             parent_id,
                                             schema_id,
                                             required: false,
                                             validation: nil,
                                             html_class: nil,
                                             readonly: false,
                                             ttip: nil,
                                             default_value: nil,
                                             overridable: nil)
    render partial: 'dynamic_form/fields/registry/multiple_complex',
           locals: {
             f: form,
             value:,
             form_prefix:,
             property_name:,
             field_label: label,
             select_values:,
             locale:,
             parent_id:,
             schema_id:,
             field_class: html_class,
             field_id:,
             readonly:,
             required:,
             validation:,
             ttip:,
             default_value:,
             overridable:
           }
  end
  # rubocop:enable  Metrics/ParameterLists

  def create_hidden_field(form, value, name)
    render partial: 'dynamic_form/fields/const_field',
           locals: {
             f: form,
             field_value: value,
             field_name: name,
             field_label: nil,
             is_const_field: false
           }
  end

  def create_const_field(form, value, name, label)
    render partial: 'dynamic_form/fields/const_field',
           locals: {
             f: form,
             field_value: value,
             field_name: name,
             field_label: label,
             is_const_field: true
           }
  end

  def display_validation_message(validations)
    message = ''
    validations.each do |validation|
      message += case validation
                 when 'required'
                   _('This property is required.')
                 when 'pattern'
                   _('This property has an invalid format.')
                 else
                   format(_('This property has an unknown problem : %{validation}'), validation:)
                 end
    end
    message
  end

  # Generate a select option "value" depending on the type of registry value
  # if it as a "complex" value, returns the id of the registry value
  # else returns the value (simple enum are save as String most of the time)
  def select_value(registry_value, locale)
    if registry_value.data['value'].present?
      registry_value.data['value'][locale] || registry_value.data['value']
    elsif registry_value.data['label'].present?
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
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def data_reformater(schema, data)
    formated_data = {}
    # rubocop:disable Metrics/BlockLength
    schema.properties.each do |key, prop|
      next if data[key].nil? || key.end_with?('_custom')

      case prop['type']
      when 'integer', 'number'
        # if data was an empty string, to_i sets the value to 0, sets it nil
        formated_data[key] = data[key].empty? ? nil : data[key].tr(' ', '').to_i
      when 'boolean'
        formated_data[key] = data[key] == '1'
      when 'array'
        formated_data[key] = data[key].is_a?(Array) ? data[key].reject(&:empty?) : [data[key]].reject(&:empty?)
      when 'object'
        next if prop['schema_id'].nil?

        sub_schema = MadmpSchema.find(prop['schema_id'])

        if prop['inputType'].eql?('pickOrCreate')
          formated_data[key] = { 'dbid' => data[key].to_i }
        elsif prop['registry_id'].present?
          # if the field is overridable, check if there's a custom value
          if prop['overridable'].present? && data["#{key}_custom"].present?
            formated_data[key] = { 'custom_value' => data["#{key}_custom"] }
            next
          end

          formated_data[key] = if data[key].present?
                                 data_reformater(
                                   sub_schema,
                                   RegistryValue.find(data[key].to_i).data.merge(
                                     id: data[key].to_i
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
        formated_data[key] = if prop['overridable'].present? && data["#{key}_custom"].present?
                               if data["#{key}_custom"].eql?('__DELETED__')
                                 ''
                               else
                                 ActionController::Base.helpers.sanitize(
                                   data["#{key}_custom"],
                                   { scrubber: DynamicFormScrubber.new }
                                 )
                               end
                             else
                               ActionController::Base.helpers.sanitize(
                                 data[key],
                                 { scrubber: DynamicFormScrubber.new }
                               )
                             end
      end

      formated_data[key] = nil if formated_data[key].eql?('')
    end
    # rubocop:enable Metrics/BlockLength
    formated_data
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Style/OptionalBooleanParameter
  def display_identifier(identifier, identifier_type, with_parenthesis = false)
    return nil if identifier.nil?

    if with_parenthesis
      "(#{identifier_type}:#{identifier})"
    else
      "#{identifier_type}:#{identifier}"
    end
  end
  # rubocop:enable Style/OptionalBooleanParameter

  # Source : https://stackoverflow.com/a/5331096
  def uri?(string)
    uri = URI.parse(string)
    %w[http https].include?(uri.scheme)
  rescue URI::BadURIError, URI::InvalidURIError
    false
  end
end
# rubocop:enable Metrics/ModuleLength
