# frozen_string_literal: true

# == Schema Information
#
# Table name: registry_values
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  description       :string
#  uri        :string
#  version    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id :integer
#

# Object that represents a registry
class Registry < ApplicationRecord
  include ValidationMessages

  # ================
  # = Associations =
  # ================

  has_many :registry_values, dependent: :destroy

  belongs_to :org, optional: true

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    where('lower(registries.name) LIKE lower(?) OR ' \
          'lower(registries.description) LIKE lower(?)',
          search_pattern, search_pattern)
  }

  def self.load_values(values_file, registry)
    return if values_file.nil?

    if values_file.respond_to?(:read)
      values_data = values_file.read
    elsif values_file.respond_to?(:path)
      values_data = File.read(values_file.path)
    else
      logger.error "Bad values_file: #{values_file.class.name}: #{values_file.inspect}"
    end
    begin
      json_values = JSON.parse(values_data)
      if json_values.key?(registry.name)
        registry.registry_values.delete_all
        registry_values = []
        json_values[registry.name].each_with_index do |reg_val, idx|
          registry_values << RegistryValue.new(data: reg_val, registry:, order: idx)
        end
        RegistryValue.import registry_values
      else
        flash.now[:alert] = 'Wrong values file format'
      end
    rescue JSON::ParserError
      flash.now[:alert] = 'File should contain JSON'
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
