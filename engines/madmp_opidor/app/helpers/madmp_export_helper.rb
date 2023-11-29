# frozen_string_literal: true

require 'jsonpath'

# Helper for JSON exports
module MadmpExportHelper
  def uri?(string)
    uri = URI.parse(string)
    %w[http https].include?(uri.scheme)
  rescue URI::BadURIError, URI::InvalidURIError
    false
  end

  def form_label(property, locale, readonly)
    if readonly
      property["label@#{locale}"]
    else
      property["form_label@#{locale}"] || property["label@#{locale}"]
    end
  end

  def load_export_template(name)
    export_format = Rails.root.join("config/madmp/exports/#{name}.json")

    JSON.parse(File.open(export_format))
  end

  def format_contributors(dmp_fragment, selected_research_outputs)
    contributors = []
    dmp_fragment.persons.each do |person|
      contributor = person.get_full_fragment
      contributor['role'] = person.roles(selected_research_outputs).uniq
      contributors.append(contributor)
    end
    contributors
  end

  def exportable_description(description)
    exportable = Loofah.fragment(description).text(encode_special_chars: false).tr("\n\r", ' ')
    return nil if exportable.eql?('')

    exportable
  end

  def extract_keywords(madmp_fragment)
    keywords = madmp_fragment.data['uncontrolledKeywords'] || []
    keywords.concat(
      madmp_fragment.controlled_keyword.pluck(Arel.sql("data->>'keyword'"))
    )
    keywords
  end
  # def madmp_transform(madmp, export_template, dmp_id)
  #   export_document = {}
  #   variable_array = {}
  #   export_template.each do |key, property|
  #     next if key.eql?("variable_name")

  #     ######################
  #     # If the property is a String
  #     ######################
  #     if property.is_a?(String)
  #       # If the string starts by "$", then it's a JsonPath
  #       if property.first.eql?("$")
  #         match = JsonPath.new(property).on(madmp).join("/")
  #         export_document[key] = match
  #       # elsif property.slice(0, 2).eql?("%%")
  #       #   export_document[key] = variable_array[property]
  #       else
  #         # Else the string should be displayed as is
  #         export_document[key] = property
  #       end
  #       next
  #     end

  #     ######################
  #     # If the property is an Array
  #     # each element is treated as a String (see above)
  #     ######################
  #     if property.is_a?(Array)
  #       export_document[key] = ""
  #       property.each do |pty|
  #         if pty.first.eql?("$")
  #           match = JsonPath.new(pty).first(madmp)
  #           export_document[key] += match if match.present?
  #         else
  #           export_document[key] += pty
  #         end
  #       end
  #       next
  #     end

  #     # if property["variable_name"].present?
  #     #   variable_array[property["variable_name"]] = madmp_transform(madmp, property, dmp_id)

  #     #   next
  #     # end

  #     ######################
  #     # If the property has a "type" and this type is "array"
  #     ######################
  #     if property["type"]&.eql?("array")
  #       items = []
  #       export_document[key] ||= []

  #       ######################
  #       # if there is a "path", extract the list of items at this path
  #       ######################
  #       if property["path"].present? && property["items"].present?
  #         if property["path"].is_a?(Array)
  #           property["path"].each do |path|
  #             items.push(JsonPath.new(path).first(madmp) || [])
  #           end
  #         else
  #           items = JsonPath.new(property["path"]).first(madmp) || []
  #         end
  #       end

  #       ######################
  #       # if there is a "classname", extract the fragment from the dabase
  #       # with a given "classname" and the params "dmp_id"
  #       # and apply the get_full_fragment function
  #       ######################
  #       if property["classname"].present? && property["items"].present?
  #         items = MadmpFragment.where(
  #           dmp_id: dmp_id, classname: property["classname"]
  #         ).map(&:get_full_fragment) || []
  #       end

  #       ######################
  #       # For each item, apply the madmp_transform again
  #       ######################
  #       items.each do |it|
  #         export_document[key].push(madmp_transform(it, property["items"], dmp_id))
  #       end

  #       next
  #     end
  #     ######################
  #     # Default treatment, apply the madmp_transform again
  #     ######################
  #     export_document[key] = madmp_transform(madmp, property, dmp_id)
  #   end
  #   export_document
  # end
end
