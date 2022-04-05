# frozen_string_literal: true

module SuperAdmin
  # Controller that handles a SupedAdmin changing their Org from the Templates page
  class OrgSwapsController < ApplicationController
    include OrgSelectable

    after_action :verify_authorized

    # rubocop:disable Metrics/AbcSize
    def create
      # Allows the user to swap their org affiliation on the fly
      authorize current_user, :org_swap?

      # See if the user selected a new Org via the Org Lookup and
      # convert it into an Org
      lookup = process_org!(user: current_user)

      # rubocop:disable Layout/LineLength
      if lookup.present? && !lookup.new_record?
        current_user.org = lookup
        if current_user.save
          redirect_back(fallback_location: root_path,
                        notice: format(_('Your organisation affiliation has been changed. You may now edit templates for %{org_name}.'),
                                       org_name: current_user.org.name))
        else
          redirect_back(fallback_location: root_path, alert: _('Unknown organisation.'))
        end
        # rubocop:enable Layout/LineLength
      else
        redirect_back(fallback_location: root_path, alert: _('Unknown organisation.'))
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
