# frozen_string_literal: true

module SuperAdmin

  module ApiClientHelper

    def label_for_scope(scope)
      case scope
      when "read_dmps"
        _("Read and Download Plans")
      when "edit_dmps"
        _("Edit Plans")
      when "create_dmps"
        _("Create Plans")
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
  end

end
