# frozen_string_literal: true

module SuperAdmin

  module ApiClientHelper

    def label_for_scope(scope)
      case scope
      when "read_public_dmps"
        _("Read Plans (publicly visible)")
      when "read_public_templates"
        _("Read Templates (publicly visible)")
      when "create_dmps"
        _("Create Plans (for Org)")
      when "authorize_users"
        _("Authorize users (OAuth2)")
      when "read_your_dmps"
        _("Read user plans")
      when "edit_your_dmps"
        _("Edit user plans")
      when "create_dmps_for_you"
        _("Create plans (for User)")
      else
        scope.humanize
      end
    end

    def tooltip_for_scope(scope)
      case scope
      when "create_dmps"
        _("Allows the API client to create DMPs for their Org (requires an Org to be specified!)")
      when "authorize_users"
        _("Allows the API client to request User authorization (OAuth2) to access their data.")
      when "read_your_dmps"
        _("Read DMPs for an authorized User")
      when "edit_your_dmps"
        _("Edit DMPs for an authorized User")
      when "create_dmps_for_you"
        _("Create DMPs for an authorized User")
      else
        ""
      end
    end
  end

end
