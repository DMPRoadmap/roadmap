# frozen_string_literal

module RegistrationsHelper

  def registration_orgs
    @registration_orgs ||= Org.where(is_other: false).order(:sort_name, :name)
  end

end
