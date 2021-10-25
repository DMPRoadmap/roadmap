# frozen_string_literal: true

module PlansHelper

  # display the role of the user for a given plan
  def display_role(role)
    if role.creator?
      _("Owner")
    elsif role.administrator?
      _("Co-owner")
    elsif role.editor?
      _("Editor")
    elsif role.commenter?
      _("Read only")
    end
  end

  # display the visibility of the plan
  def display_visibility(val)
    case val
    when 'organisationally_visible'
      return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Organisation')}</span>"
    when 'publicly_visible'
      return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Public')}</span>"
    when 'privately_visible'
      return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Private')}</span>"
    when 'is_test'
      return "<span title=\"#{ visibility_tooltip(val) }\">#{_('Test')}</span>"
    else 
      return "<span>N/A</span>"
    end
  end

  def visibility_tooltip(val)
    case val
    when 'organisationally_visible'
      _('Organisation: anyone at my organisation can view.')
    when 'publicly_visible'
      _('Public: anyone can view.')
    when 'privately_visible'
      _('Private: restricted to me and people I invite.')
    when 'is_test'
      _('Test: mock project for testing, practice, or educational purposes.')
    else
      _('N/A')
    end
  end

  def visibility_options(val)
    case val
    when 'organisationally_visible'
      _('Organisation')
    when 'publicly_visible'
      _('Public')
    when 'privately_visible'
      _('Private')
    when 'is_test'
      _('Test')
    else
      _('N/A')
    end
  end

  def download_plan_page_title(plan, phase, hash)
    # If there is more than one phase show the plan title and phase title
    hash[:phases].many? ? "#{plan.title} - #{phase[:title]}" : plan.title
  end

  def display_section?(customization, section, show_custom_sections)
    display = !customization
    display ||= customization && !section[:modifiable]
    display ||= customization && section[:modifiable] && show_custom_sections
    display
  end

end
