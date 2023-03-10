# frozen_string_literal: true

# Generator class for creating a new Rule to clean DB records.
class DataCleanupRuleGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates/data_cleanup/rules', __dir__)

  # Copy the Rule template and create a new Rule file
  def add_rule_file
    empty_directory 'lib/data_cleanup/rules'
    template 'base.rb', base_class_path unless File.exist?(base_class_path)
    template 'rule.rb.erb', rule_path.to_s
  end

  private

  def base_class_path
    Rails.root.join('lib', 'data_cleanup', 'rules', 'base.rb')
  end

  # The name of the model we're fixing (e.g. 'User')
  #
  # Returns String
  def model_name
    file_path.split('/').first.classify
  end

  # The name of the Rule class we're creating (e.g. 'User::FixBlankEmail')
  #
  # Returns String
  def rule_class_name
    file_path.split('/').last.classify
  end

  # The file path for the new Rule class
  #
  # Returns String
  def rule_path
    Rails.root.join('lib', 'data_cleanup', 'rules', "#{file_path}.rb")
  end

  # A default description to populate the Rule#description method
  #
  # Returns String
  def default_description
    format('%{rule_name} on %{model_name}',
           rule_name: rule_class_name.underscore
                                     .split('_')
                                     .join(' ')
                                     .capitalize, model_name: model_name.classify)
  end
end
