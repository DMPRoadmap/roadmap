module Dmpopidor
    module Controllers
      module Application
        # Set Static Pages collection to use in navigation
        def set_nav_static_pages
            @nav_static_pages = StaticPage.navigable
        end
        # Added Dataset Support
        def obj_name_for_display(obj)
          display_name = {
            Dataset: d_('dmpopidor', "dataset"),
            ExportedPlan: _("plan"),
            GuidanceGroup: _("guidance group"),
            Note: _("comment"),
            Org: _("organisation"),
            Perm: _("permission"),
            Pref: _("preferences"),
            User: obj == current_user ? _("profile") : _("user")
          }
          if obj.respond_to?(:customization_of) && obj.send(:customization_of).present?
            display_name[:Template] = "customization"
          end
          display_name[obj.class.name.to_sym] || obj.class.name.downcase || "record"
        end



        def success_message(obj, action = "saved")
          d_('dmpopidor', "Successfully %{action} the %{object}.") % {
            object: obj_name_for_display(obj),
            action: action || "save",
          }
        end
      end
    end
  end