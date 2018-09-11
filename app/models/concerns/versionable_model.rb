module VersionableModel

  extend ActiveSupport::Concern

  included do

    attr_readonly :versionable_id

    before_validation :set_versionable_id, unless: :versionable_id?

  end

  private

  def set_versionable_id
    self.versionable_id = SecureRandom.uuid
  end

end