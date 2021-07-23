# frozen_string_literal: true

module SuperAdmin

  module ApiClientHelper

    # Helper that gives human readable context to Doorkeeper OAuth scopes

    def label_for_scope(scope)
      case scope
      when "read_dmps"
        _("Read and download PDF copies of plans")
      when "edit_dmps"
        _("Edit plans")
      when "create_dmps"
        _("Create plans")
      when "public"
        _("Retrieve a list of templates and plans")
      else
        scope.humanize
      end
    end

    def tooltip_for_scope(scope)
      case scope
      when "read_dmps"
        _("Access to all publicly visible plans and, if associated with an org, the organisationally visible plans. They can also access a user's plans through OAuth autorization.")
      when "edit_dmps"
        _("Edit any plans created through the API and edit a user's plan after gaining OAuth authorization from the user")
      when "create_dmps"
        _("Create a plan (will be associated with the Org defined here if applicable) and create plans on behalf of a user once OAuth auuthorization has been granted")
      else
        ""
      end
    end

    # This one is used on the app/views/doorkeeper/authorizations/new.html.erb for user's authorizing
    def user_label_for_scope(scope)
      case scope
      when "read_dmps"
        _("Read and download your DMPs")
      when "edit_dmps"
        _("Edit your DMPs")
      when "create_dmps"
        _("Create DMPs on your behalf")
      when "public"
        _("Retrieve a list of your DMPs")
      else
        scope.humanize
      end
    end
  end

end
