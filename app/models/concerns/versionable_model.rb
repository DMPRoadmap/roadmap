# frozen_string_literal: true

# Module that allows a Model to be versioned
module VersionableModel
  extend ActiveSupport::Concern

  included do
    extend UniqueRandom

    attr_readonly :versionable_id

    attribute :versionable_id,
              :string,
              default: lambda {
                         unique_uuid(field_name: 'versionable_id')
                       }
  end
end
