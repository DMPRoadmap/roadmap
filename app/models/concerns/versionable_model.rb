# frozen_string_literal: true

module VersionableModel

  extend ActiveSupport::Concern

  included do
    extend UniqueRandom

    attr_readonly :versionable_id

    attribute :versionable_id,
              :string,
              default: lambda {
                         unique_uuid(field_name: "versionable_id")
                       }
  end

end
