# frozen_string_literal: true

require 'data_cleanup'

namespace :data_cleanup do
  desc 'Check each record on the DB is valid and report'
  task find_invalid_records: :environment do
    DataCleanup.logger.info("\n== Finding invalid records =======================\n")
    models.each do |model|
      DataCleanup::ModelCheck.new(model).call
    end
    DataCleanup::Reporting.prepare!
    DataCleanup::Reporting.report
  end

  desc 'Clean invalid records on the database'
  task clean_invalid_records: :environment do
    DataCleanup.logger.info("\n== Cleaning invalid records =======================\n")
    Dir[rule_paths].each do |rule_path|
      load rule_path
      klass_name = rule_path.split('rules/').last.gsub('.rb', '').classify
      model_name = klass_name.split('::').first
      opt, models = ARGV[1].to_s.split('=')
      if opt.present? && opt == 'INCLUDE'
        next unless model_name.in?(models.split(','))
      elsif opt.present? && opt == 'EXCLUDE'
        next if model_name.in?(models.split(','))
      elsif opt.blank?
        # :noop:
      else
        raise ArgumentError, "Unknown option: #{opt}"
      end
      rule_class = DataCleanup::Rules.const_get(klass_name)
      rule       = rule_class.new
      puts rule.description
      rule.call
    end
  end

  desc 'Check records for validation errors'
  task find_known_invalidations: :environment do
    models.each do |model|
      DataCleanup.display "Checking #{model.name} records"
      next unless model.respond_to?(:_validate_callbacks)

      model._validate_callbacks.to_a.collect(&:filter).each do |filter|
        ids = []
        msg = ''

        case filter.class.name
        when 'ActiveRecord::Validations::PresenceValidator'
          ids, msg = check_presence(model, filter)

        when 'ActiveRecord::Validations::UniquenessValidator'
          ids, msg = check_uniqueness(model, filter)

        when 'ActiveModel::Validations::InclusionValidator'
          ids, msg = check_inclusion(model, filter)

        when 'ActiveModel::Validations::FormatValidator'
          ids, msg = check_format(model, filter)

        when 'ActiveModel::Validations::LengthValidator'
          ids, msg = check_length(model, filter)

        when 'ActiveModel::Validations::NumericalityValidator'
          ids, msg = check_numericality(model, filter)

        when 'ActiveModel::Validations::ConfirmationValidator'
          # Skip

        when 'Dragonfly::Model::Validations::PropertyValidator'
          # Skip

        when 'Symbol'
          # Skip

        when 'OrgLinksValidator'
          ids, msg = check_local_validators(model, [:links], 'OrgLinksValidator')

        when 'TemplateLinksValidator'
          # Skip
          ids, msg = check_local_validators(model, [:links], 'TemplateLinksValidator')

        when 'EmailValidator'
          # Skip
          ids, msg = check_local_validators(model, filter.attributes, 'EmailValidator')

        when 'AfterValidator'
          # Skip
          ids, msg = check_local_validators(model, filter.attributes, 'AfterValidator')

        else
          p "Unhandled validator type: #{filter.class.name}"
          p filter.inspect
        end

        if msg.present?
          DataCleanup.display msg, color: ids.any? ? :red : :green
        end
      end
    end
  end

  desc 'Deactivate the roles and plan for any plan that no longer has an owner'
  task deactivate_orphaned_plans: :environment do
    p 'Deactiviating plans that no longer have a owner, coowner or editor'
    Plan.all.each(&:deactivate!)
    p 'Done'
  end

  private

  def report_known_invalidations(results, model_name, validation_error)
    DataCleanup.display "#{results.count} #{model_name.pluralize} with #{validation_error}",
                        color: results.any? ? :red : :green
  end

  def rule_paths
    @rule_paths ||= Rails.root.join('lib', 'data_cleanup', 'rules', '*', '*.rb')
  end

  def models
    Dir[Rails.root.join('app', 'models', '*.rb')].map do |model_path|
      model_path.split('/').last.gsub('.rb', '').classify.constantize
    end.sort_by(&:name)
  end

  def singular?(value)
    str = value.to_s
    # p "#{str.pluralize} != #{str} && #{str.singularize} == #{str}"
    str.pluralize != str && str.singularize == str
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def check_presence(klass, filter)
    table = klass.name.tableize
    instance = klass.new
    ids = []
    msg = ''
    filter.attributes.map(&:to_s).each do |attr|
      join = attr.pluralize.tableize

      # Determine if its an association so we can check for orphans
      if models.map(&:name).include?(attr.camelize)
        # Determine if the model is a child in the relationship
        if singular?(attr)
          ids = klass.joins("LEFT OUTER JOIN #{join} ON #{join}.id = #{table}.#{attr}_id")
                     .where(join.to_sym => { id: nil })
          msg = "  #{ids.count} orphaned records due to nil or missing #{attr}"
        end

      elsif instance.send(attr.to_sym).is_a?(ActiveRecord::Associations::CollectionProxy)
        # If the instance is an association in the other direction just make sure
        # it has children

        # Skip this one becausue Guidance <--> Themes is a many to many join and this
        # particular validation is handled elsewhere

      else
        unless attr == 'password'
          # Find any records where the field is blank or nil
          ids = if filter.options.present? && filter.options[:if].present?
                  klass.where(attr.to_sym => [nil, '']).select { |r| r.send(filter.options[:if]) }.map(&:id)
                else
                  klass.where(attr.to_sym => [nil, ''])
                end
          msg = "  #{ids.count} records with a empty #{attr} field"
        end
      end
    end
    [ids, msg]
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # rubocop:disable Metrics/AbcSize
  def check_uniqueness(klass, filter)
    instance = klass.new
    group = [filter.attributes.map { |a| instance.respond_to?(:"#{a}_id") ? :"#{a}_id".to_sym : a }]

    group << filter.options[:scope] if filter.options[:scope].present?
    group = group.flatten.uniq
    ids = klass.group(group).count.select { |_k, v| v > 1 }
    [ids, "  #{ids.count} records that are not unique per (#{group.join(', ')})"]
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def check_inclusion(klass, filter)
    ids = []
    msg = ''
    if filter.options[:in].present?
      filter.attributes.each do |attr|
        ids << klass.where.not(attr.to_sym => filter.options[:in]).pluck(:id)
      end
      ids = ids.flatten.uniq
      # rubocop:disable Layout/LineLength
      msg = "  #{ids.count} records that do not have a valid value for #{filter.attributes}, should be #{filter.options[:in]}"
      # rubocop:enable Layout/LineLength
    end
    [ids, msg]
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def check_format(klass, filter)
    ids = []
    if filter.options[:with].present?
      filter.attributes.each do |attr|
        # skip password validaton since the field is encrypted through Devise
        unless attr == :password
          # If this is the users.email field send it to the EmailValidator. Devise has its own Regex
          # but running a Regex query gets messy between different DB types
          if klass.name == 'User' && attr == :email
            ids, _msg = check_local_validators(klass, [attr], EmailValidator)
          else
            ids = klass.where.not(attr.to_sym => filter.options[:when]).pluck(:id)
          end
        end
      end
      ids = ids.flatten.uniq
    end
    [ids.flatten.uniq, "  #{ids.count} records that do not have valid #{filter.attributes}"]
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def check_length(klass, filter)
    ids = []
    shoulda = ''
    skippable = %i[password logo]
    filter.attributes.each do |attr|
      next if skippable.include?(attr)

      qry = ''
      if filter.options[:minimum].present?
        qry += "CHAR_LENGTH(#{attr}) < #{filter.options[:minimum]}"
        shoulda += ">= #{filter.options[:maximum]}"
      end

      if filter.options[:maximum].present?
        unless qry.blank?
          qry += ' OR '
          shoulda += ' and '
        end
        qry += "CHAR_LENGTH(#{attr}) > #{filter.options[:maximum]}"
        shoulda += "<= #{filter.options[:maximum]}"
      end

      ids << klass.where(qry).pluck(:id) unless qry.blank?
    end
    ids = ids.flatten.uniq
    [ids, "  #{ids.count} records that are an invalid length for fields #{filter.attributes} should be #{shoulda}"]
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def check_numericality(klass, filter)
    filter.attributes.each do |attr|
      qry = ''
      shoulda = ''
      if filter.options[:only_integer].present?
        qry = "CEIL(#{attr}) != #{attr}"
        shoulda = 'been an integer'
      end
      if filter.options[:greater_than].present?
        qry += qry.blank? ? '' : ' OR '
        shoulda += shoulda.blank? ? '' : ' and '
        qry += "#{attr} <= #{filter.options[:greater_than]}"
        shoulda += " length > #{filter.options[:greater_than]}"
      end
      if filter.options[:less_than].present?
        qry += qry.blank? ? '' : ' OR '
        shoulda += shoulda.blank? ? '' : ' and '
        qry += "#{attr} >= #{filter.options[:less_than]}"
        shoulda += " length < #{filter.options[:less_than]}"
      end

      ids = klass.where(qry).pluck(:id)
      msg = "  #{ids.count} records that are an invalid #{filter.attributes} because it should #{shoulda}"
      [ids, msg]
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def check_local_validators(klass, attributes, validator)
    ids = []
    klass.all.each do |obj|
      obj.valid?
      attributes.each do |attr|
        ids << obj.id unless obj.errors[attr.to_sym].blank?
      end
    end
    ids = ids.flatten.uniq
    [ids, "  #{ids.count} records that have an invalid #{attributes}. See the #{validator} for further details"]
  end
end
