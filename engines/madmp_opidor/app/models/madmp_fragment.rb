# frozen_string_literal: true

# == Schema Information
#
# Table name: madmp_fragments
#
#  id                        :integer          not null, primary key
#  data                      :json
#  answer_id                 :integer
#  madmp_schema_id :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  classname                 :string
#  dmp_id                    :integer
#  parent_id                 :integer
#
# Indexes
#
#  index_madmp_fragments_on_answer_id                  (answer_id)
#  index_madmp_fragments_on_madmp_schema_id  (madmp_schema_id)
#
require 'jsonpath'

# rubocop:disable Metrics/ClassLength
# Object that represents a madmp_fragment
class MadmpFragment < ApplicationRecord
  include ValidationMessages
  include DynamicFormHelper
  include FragmentImport
  include ActionView::Helpers::NumberHelper

  # ================
  # = Associations =
  # ================

  belongs_to :answer, optional: true
  belongs_to :madmp_schema, class_name: 'MadmpSchema'
  belongs_to :dmp, class_name: 'Fragment::Dmp', foreign_key: 'dmp_id', optional: true
  has_many :children, class_name: 'MadmpFragment', foreign_key: 'parent_id', dependent: :destroy
  belongs_to :parent, class_name: 'MadmpFragment', foreign_key: 'parent_id', optional: true

  # ===============
  # = Validations =
  # ===============

  # validates :madmp_schema, presence: { message: PRESENCE_MESSAGE }
  validates :dmp, presence: true, unless: -> { classname.eql?('dmp') }

  # ================
  # = Single Table Inheritence =
  # ================
  self.inheritance_column = :classname
  scope :backup_policies, -> { where(classname: 'backup_policy') }
  scope :budgets, -> { where(classname: 'budgets') }
  scope :contributors, -> { where(classname: 'contributor') }
  scope :costs, -> { where(classname: 'cost') }
  scope :data_collections, -> { where(classname: 'data_collection') }
  scope :data_preservations, -> { where(classname: 'data_preservation') }
  scope :data_processings, -> { where(classname: 'data_processing') }
  scope :data_reuses, -> { where(classname: 'data_reuse') }
  scope :data_sharings, -> { where(classname: 'data_sharing') }
  scope :data_storages, -> { where(classname: 'data_storage') }
  scope :distributions, -> { where(classname: 'distribution') }
  scope :dmps, -> { where(classname: 'dmp') }
  scope :documentation_qualities, -> { where(classname: 'documentation_quality') }
  scope :ethical_issues, -> { where(classname: 'ethical_issue') }
  scope :funders, -> { where(classname: 'funder') }
  scope :fundings, -> { where(classname: 'funding') }
  scope :hosts, -> { where(classname: 'host') }
  scope :legal_issues, -> { where(classname: 'legal_issue') }
  scope :licences, -> { where(classname: 'licence') }
  scope :metas, -> { where(classname: 'meta') }
  scope :metadata_standards, -> { where(classname: 'metadata_standard') }
  scope :partners, -> { where(classname: 'partner') }
  scope :persons, -> { where(classname: 'person') }
  scope :personal_data_issues, -> { where(classname: 'personal_data_issue') }
  scope :projects, -> { where(classname: 'project') }
  scope :research_outputs, -> { where(classname: 'research_output') }
  scope :research_output_descriptions, -> { where(classname: 'research_output_description') }
  scope :resource_references, -> { where(classname: 'resource_reference') }
  scope :research_entities, -> { where(classname: 'research_entity') }
  scope :reused_datas, -> { where(classname: 'reused_data') }
  scope :specific_datas, -> { where(classname: 'specific_data') }
  scope :technical_resources, -> { where(classname: 'technical_resource') }

  # =============
  # = Callbacks =
  # =============

  before_save   :set_defaults
  after_create  :update_parent_references
  after_destroy :update_parent_references
  after_save    :update_research_output_parameters

  # =====================
  # = Nested Attributes =
  # =====================
  accepts_nested_attributes_for :answer, allow_destroy: true

  # ========================
  # = Public class methods =
  # ========================

  def plan
    if dmp.nil?
      Plan.find(data['plan_id'])
    else
      dmp.plan
    end
  end

  # Returns the schema associated to the JSON fragment
  def json_schema
    madmp_schema.schema
  end

  def dmp_fragments
    MadmpFragment.where(dmp_id: dmp.id)
  end

  # Returns a human readable version of the structured answer
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
  def to_s
    return additional_info['custom_value'] if additional_info['custom_value'].present?

    full_data = get_full_fragment
    displayable = ''
    if json_schema['to_string']
      json_schema['to_string'].each do |pattern|
        # if it's a JsonPath pattern
        if pattern.first == '$'
          match = JsonPath.on(full_data, pattern)

          next if match.empty? || match.first.nil?

          displayable += case match.first
                         when Array
                           match.first.join('/')
                         when Integer, Float
                           number_with_delimiter(match.first)
                         else
                           match.first
                         end
        else
          displayable += pattern
        end
      end
    else
      displayable = full_data.to_s
    end
    displayable
  end
  # rubocop:enable Metrics/MethodLength, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

  # This method generates references to the child fragments in the parent fragment
  # it updates the json "data" field in the database
  # it groups the children fragment by classname and extracts the list of ids
  # to create the json structure needed to update the "data" field
  # this method should be called when creating or deleting a child fragment
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def update_children_references
    updated_data = data
    classified_children = children.group_by do |t|
      t.additional_info['property_name'] unless t.additional_info.nil?
    end

    madmp_schema.properties.each do |key, prop|
      if prop['type'].eql?('array') && prop['items']['type'].eql?('object')
        updated_data[key] = []
        if classified_children[key].present?
          updated_data[key] = classified_children[key].map { |c| { 'dbid' => c.id } }
          next
        end
      elsif prop['type'].eql?('object') && prop['schema_id'].present?
        # dbid doesn't need to be regenerated for "person" properties
        # Person fragment don't have a parent_id set because they are used in multiple contributors
        # without this instruction, the app would set the dbid for the person prop as nil
        next if key.eql?('person')

        updated_data[key] = classified_children[key].nil? ? nil : { 'dbid' => classified_children[key][0].id }
      end
    end
    update!(data: updated_data)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize

  def update_parent_references
    return if classname.nil? || parent.nil?

    parent.update_children_references
  end

  def update_research_output_parameters
    case classname
    when 'research_output_description'
      ro_fragment = parent
      new_additional_info = ro_fragment.additional_info.merge(
        hasPersonalData: %w[Oui Yes].include?(data['containsPersonalData'])
      )
      ro_fragment.update(additional_info: new_additional_info)
      ResearchOutputChannel.broadcast_to(research_output, research_output.serialize_infobox_data)
    else
      return
    end
  end

  # This method return the fragment full record
  # It integrates its children into the JSON
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_full_fragment(with_ids: false, with_template_name: false)
    if additional_info['custom_value'].present?
      {
        'custom_value' => additional_info['custom_value']
      }
    end

    children = self.children
    editable_data = data
    # rubocop:disable Metrics/BlockLength
    editable_data.each do |prop, value|
      if value.is_a?(Hash) && value['dbid'].present?
        child = if children.exists?(value['dbid'])
                  children.find(value['dbid'])
                else
                  MadmpFragment.find(value['dbid'])
                end
        child_data = if child.additional_info['custom_value'].present?
                       { 'custom_value' => child.additional_info['custom_value'] }
                     else
                       child.get_full_fragment(
                         with_ids:,
                         with_template_name:
                       )
                     end
        editable_data = editable_data.merge(prop => child_data)
        next
      end

      if value.is_a?(Array)
        next if value.empty?

        fragment_tab = []
        value.each do |v|
          next if v.nil?

          if v.is_a?(Hash) && v['dbid'].present?
            child_data = if children.exists?(v['dbid'])
                           children.find(v['dbid'])
                         else
                           MadmpFragment.find(v['dbid'])
                         end
            fragment_tab.push(
              child_data.get_full_fragment(
                with_ids:,
                with_template_name:
              )
            )
          else
            fragment_tab.push(v)
          end
          editable_data = editable_data.merge(prop => fragment_tab)
        end
        next
      end
      editable_data[prop] = value
    end
    # rubocop:enable Metrics/BlockLength
    editable_data = { 'id' => id, 'schema_id' => madmp_schema_id }.merge(editable_data) if with_ids
    editable_data = { 'template_name' => madmp_schema.name }.merge(editable_data) if with_template_name

    editable_data
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # This method take a fragment and convert its data with the target schema
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def schema_conversion(target_schema, locale)
    origin_schema_properties = madmp_schema.properties
    target_schema_defaults = target_schema.defaults(locale)
    converted_data = {}

    # rubocop:disable Metrics/BlockLength
    target_schema.properties.each do |key, target_prop|
      origin_prop = origin_schema_properties[key]
      next if origin_prop.nil?

      if target_prop['type'].eql?('array')
        converted_data[key] = data[key].is_a?(Array) ? data[key] : [data[key]]
        if target_prop['items']['type'].eql?('object')
          next if converted_data[key].empty? || converted_data[key].first.nil?

          target_sub_schema = MadmpSchema.find(target_prop['items']['schema_id'])
          converted_data[key].map { |v| MadmpFragment.find(v['dbid']).schema_conversion(target_sub_schema, locale) }
        end
      elsif origin_prop['type'].eql?('object')
        converted_data[key] = data[key]
        next if origin_prop['inputType'].present? && origin_prop['inputType'].eql?('pickOrCreate')

        sub_fragment = MadmpFragment.find(data[key]['dbid'])
        target_sub_schema = MadmpSchema.find(target_prop['schema_id'])
        sub_fragment.schema_conversion(target_sub_schema, locale)
      elsif origin_prop['type'].eql?('array')
        if target_prop['type'].eql?('object')
          target_sub_schema = MadmpSchema.find(target_prop['schema_id'])
          data[key] = [] if data[key].nil?
          if data[key].empty?
            sub_fragment = MadmpFragment.new(
              data: {},
              answer_id: nil,
              dmp_id: dmp.id,
              parent_id: id,
              madmp_schema: target_sub_schema,
              additional_info: { property_name: key }
            )
            sub_fragment.assign_attributes(classname: sub_fragment.classname)
            sub_fragment.instantiate
          else
            first_id = data[key].first['dbid']
            MadmpFragment.find(first_id).schema_conversion(target_sub_schema, locale)
            converted_data[key] = { 'dbid' => first_id }
          end
        else
          converted_data[key] = data[key].first
        end
      else
        converted_data[key] = data[key]
      end
    end
    # rubocop:enable Metrics/BlockLength
    update!(
      data: converted_data,
      madmp_schema_id: target_schema.id
    )
    handle_defaults(target_schema_defaults)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # This method is called when a form is opened for the first time
  # It creates the whole tree of sub_fragments
  # rubocop:disable Metrics/AbcSize
  def instantiate
    save! if id.nil?

    new_data = data || {}
    madmp_schema.properties.each do |key, prop|
      next unless prop['type'].eql?('object') && prop['schema_id'].present?

      sub_schema = MadmpSchema.find(prop['schema_id'])

      next if sub_schema.classname.eql?('person') || new_data[key].present?

      sub_fragment = MadmpFragment.new(
        data: {},
        answer_id: nil,
        dmp_id: dmp.id,
        parent_id: id,
        madmp_schema: sub_schema,
        additional_info: { property_name: key }
      )
      sub_fragment.assign_attributes(classname: sub_schema.classname)
      sub_fragment.instantiate

      new_data[key] = { 'dbid' => sub_fragment.id }
    end
    update!(data: new_data)
  end
  # rubocop:enable Metrics/AbcSize

  def handle_defaults(defaults)
    raw_import(defaults, madmp_schema) # if defaults.any?
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def save_form_fragment(param_data, schema)
    fragmented_data = {}
    return if param_data.nil?

    # rubocop:disable Metrics/BlockLength
    param_data.each do |prop, content|
      schema_prop = schema.properties[prop]

      next if schema_prop&.dig('type').nil?

      if schema_prop['type'].eql?('object') &&
         schema_prop['schema_id'].present?
        sub_data = content # TMP: for readability
        sub_schema = MadmpSchema.find(schema_prop['schema_id'])
        instantiate unless data[prop].present?

        if schema_prop&.dig('inputType').eql?('pickOrCreate')
          fragmented_data[prop] = content
        elsif schema_prop['overridable'].present? &&
              param_data.dig(prop, 'custom_value').present?
          # if the property is overridable & value is custom, take the value as is
          sub_fragment = MadmpFragment.find(data[prop]['dbid'])
          additional_info = if param_data.dig(prop, 'custom_value').eql?('__DELETED__')
                              {}
                            else
                              sub_fragment.additional_info.merge(sub_data)
                            end
          sub_fragment.update(
            data: {},
            additional_info:
          )
        elsif data.dig(prop, 'dbid')
          sub_fragment = MadmpFragment.find(data[prop]['dbid'])
          sub_fragment.save_form_fragment(sub_data, sub_schema)
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
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def get_property(property_name)
    return if data.empty? || data[property_name].nil?

    if data[property_name]['dbid'].present?
      MadmpFragment.find(data[property_name]['dbid'])
    else
      data[property_name]
    end
  end

  # Get the research output fragment from the fragment hierarchy
  def research_output_fragment
    return nil if %w[meta dmp project research_entity budget].include?(classname)

    return self if classname.eql?('research_output')

    parent.research_output_fragment
  end

  def research_output_id
    return nil if research_output_fragment.nil?

    research_output_fragment.data['research_output_id']
  end

  def research_output
    return nil if research_output_fragment.nil?

    ResearchOutput.find(research_output_fragment.data['research_output_id'])
  end

  # rubocop:disable Metrics/AbcSize
  def update_meta_fragment
    meta_fragment = dmp.meta
    if classname.eql?('project')
      project_fragment = self
      dmp_title = format(_('"%{project_title}" project DMP'), project_title: project_fragment.data['title'])
      meta_data = meta_fragment.data.merge(
        'title' => dmp_title, 'lastModifiedDate' => plan.updated_at.strftime('%F')
      )
      plan.update(title: dmp_title)
    else
      plan.update(title: meta_fragment.data['title'])
      meta_data = meta_fragment.data.merge(
        'lastModifiedDate' => plan.updated_at.strftime('%F')
      )
    end
    meta_fragment.update(data: meta_data)
  end
  # rubocop:enable Metrics/AbcSize

  # =================
  # = Class methods =
  # =================

  # Validate the fragment data with the linked schema
  # and saves the result with the fragment data
  # rubocop:disable Metrics/AbcSize
  def self.validate_data(data, schema)
    schemer = JSONSchemer.schema(schema)
    unformated = schemer.validate(data).to_a
    validations = {}
    unformated.each do |valid|
      next if valid['type'].eql?('object')

      key = valid['data_pointer'][1..]
      if valid['type'].eql?('required')
        required = JsonPath.on(valid, '$..missing_keys').flatten
        required.each do |req|
          validations[req] ? validations[req].push('required') : validations[req] = ['required']
        end
      else
        validations[key] ? validations[key].push(valid['type']) : validations[key] = [valid['type']]
      end
    end
    validations
  end
  # rubocop:enable Metrics/AbcSize

  # Checks for a given dmp_id (and parent_id) if a fragment exists in the database
  # rubocop:disable Metrics/AbcSize
  def self.fragment_exists?(data, schema, dmp_id, parent_id = nil, current_fragment_id = nil)
    return false if schema.schema['unicity'].nil? || schema.schema['unicity'].empty?

    classname = schema.classname
    parent_id = nil if classname.eql?('person')
    unicity_properties = schema.schema['unicity']
    dmp_fragments = MadmpFragment.where(
      dmp_id:,
      parent_id:,
      classname:
    ).where.not(id: current_fragment_id)

    dmp_fragments.each do |fragment|
      filtered_db_data = fragment.data.slice(*unicity_properties).compact
      filtered_incoming_data = data.to_h.slice(*unicity_properties).compact
      next if filtered_db_data.empty?

      return fragment if filtered_db_data.eql?(filtered_incoming_data)
    end
    false
  end
  # rubocop:enable Metrics/AbcSize

  def self.deep_copy(fragment, answer_id, ro_fragment)
    fragment_copy = MadmpFragment.new(
      dmp_id: ro_fragment.dmp_id,
      parent_id: ro_fragment.id,
      answer_id:,
      madmp_schema_id: fragment.madmp_schema_id,
      additional_info: { property_name: fragment.additional_info['property_name'] }
    )
    fragment_copy.classname = fragment.classname
    fragment_copy.instantiate
    fragment_copy.raw_import(
      fragment.get_full_fragment,
      fragment.madmp_schema
    )
    fragment_copy
  end

  def self.find_sti_class(_type_name)
    self
  end

  private

  # Initialize the data field
  def set_defaults
    self.data ||= {}
    self.additional_info ||= {}
    self.parent_id = nil if classname.eql?('person')
  end
end
# rubocop:enable Metrics/ClassLength
