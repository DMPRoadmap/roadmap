require "data_cleanup"

namespace :data_cleanup do

  desc "Check each record on the DB is valid and report"
  task :find_invalid_records => :environment do
    models.each do |model|
      DataCleanup::ModelCheck.new(model).call
    end
    DataCleanup::Reporting.prepare!
    DataCleanup::Reporting.report
  end

  desc "Clean invalid records on the database"
  task :clean_invalid_records => :environment do
    Dir[rule_paths].each do |rule_path|
      load rule_path
      klass_name = rule_path.split("rules/").last.gsub(".rb", '').classify
      model_name = klass_name.split("::").first
      opt, models = ARGV[1].to_s.split("=")
      case opt
      when 'INCLUDE'
        next unless model_name.in?(models.split(","))
      when 'EXCLUDE'
        next if model_name.in?(models.split(","))
      else
        raise ArgumentError, "Unknown option: #{opt}"
      end
      rule_class = DataCleanup::Rules.const_get(klass_name)
      rule       = rule_class.new
      puts rule.description
      rule.call
    end
  end

  private

  def rule_paths
    @rule_paths ||= Rails.root.join("lib", "data_cleanup", "rules", "*", "*.rb")
  end

  def models
    Dir[Rails.root.join("app", "models", "*.rb")].map do |model_path|
      model_path.split("/").last.gsub(".rb", "").classify.constantize
    end.sort_by(&:name)
  end
end

