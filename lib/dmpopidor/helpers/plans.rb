module Dmpopidor
    module Helpers
      module Plans
        # display the name of the owner of a plan
        # CHANGE : Added translation
        def display_owner(user)
          if user == current_user
            name = d_('dmpopidor', 'You')
          else
            name = user&.name(false)
          end
          return name
        end

        # display the visibility of the plan
        # CHANGE : Added privately_private_visible visibility
        def display_visibility(val)
          case val
          when 'organisationally_visible'
            return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Organisation')}</span>"
          when 'publicly_visible'
            return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Public')}</span>"
          when 'privately_visible'
            return "<span title=\"#{ visibility_tooltip(val) }\">#{d_('dmpopidor', 'Administrator')}</span>"
          when 'privately_private_visible'
            return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Private')}</span>"
          else
            return "<span>#{_('Private')}</span>" # Test Plans
        end
      end

      # CHANGE : Added privately_private_visible visibility
      def visibility_tooltip(val)
        case val
        when 'organisationally_visible'
          return _('Organisation: anyone at my organisation can view.')
        when 'publicly_visible'
          return _('Public: anyone can view.')
        when 'privately_visible'
          return d_('dmpopidor', 'Administrator: visible to me, specified collaborators and administrators at my organisation.')
        else
          return _('Private: restricted to me and people I invite.')
        end
      end

    end
  end
end