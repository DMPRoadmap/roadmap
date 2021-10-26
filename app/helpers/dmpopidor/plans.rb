# frozen_string_literal: true

module Dmpopidor

  module Plans

    # display the name of the owner of a plan
    # CHANGE : Added translation
    def display_owner(owner)
      name = if owner == current_user
               d_("dmpopidor", "You")
             else
               owner&.name(false)
             end
      name
    end

    # display the visibility of the plan
    # CHANGE : Added administrator_visible visibility
    def display_visibility(val)
      case val
      when "organisationally_visible"
        "<span title=\"#{ visibility_tooltip(val) }\">#{_('Organisation')}</span>"
      when "publicly_visible"
        "<span title=\"#{ visibility_tooltip(val) }\">#{_('Public')}</span>"
      when "administrator_visible"
        "<span title=\"#{ visibility_tooltip(val) }\">#{d_('dmpopidor', 'Administrator')}</span>"
      when "privately_visible"
        "<span title=\"#{ visibility_tooltip(val) }\">#{_('Private')}</span>"
      else
        "<span>#{_('Private')}</span>" # Test Plans
      end
    end

    # CHANGE : Added administrator_visible visibility
    def visibility_tooltip(val)
      case val
      when "organisationally_visible"
        _("Organisation: anyone at my organisation can view.")
      when "publicly_visible"
        _("Public: anyone can view.")
      when "administrator_visible"
        d_("dmpopidor", "Administrator: visible to me, specified collaborators and administrators at my organisation.")
      else
        _("Private: restricted to me and people I invite.")
      end
    end

  end

end
