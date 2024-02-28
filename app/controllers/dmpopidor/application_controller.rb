# frozen_string_literal: true

module Dmpopidor
  # Customized code for ApplicationController
  module ApplicationController
    # Set Static Pages collection to use in navigation
    def set_nav_static_pages
      @nav_static_pages = StaticPage.navigable
    end

    # Added Research output Support
    # rubocop:disable Metrics/AbcSize
    def obj_name_for_display(obj)
      display_name = {
        ApiClient: _('API client'),
        ResearchOutput: _('research output'),
        ExportedPlan: _('plan'),
        GuidanceGroup: _('guidance group'),
        Note: _('comment'),
        Org: _('organisation'),
        Perm: _('permission'),
        Pref: _('preferences'),
        Department: _('department'),
        User: obj == current_user ? _('profile') : _('user'),
        QuestionOption: _('question option'),
        MadmpSchema: _('schema'),
        Registry: _('registry'),
        RegistryValue: _('registry value')
      }
      if obj.respond_to?(:customization_of) && obj.send(:customization_of).present?
        display_name[:Template] = 'customization'
      end
      display_name[obj.class.name.to_sym] || obj.class.name.downcase || 'record'
    end
    # rubocop:enable Metrics/AbcSize

    def after_sign_in_path_for(_resource)
      plans_path(anchor: 'content')
    end
  end
end
