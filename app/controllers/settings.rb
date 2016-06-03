module Settings
  class SettingsController < ApplicationController
    before_filter do
      authorize! :manage_settings, current_user
    end
  end
end
