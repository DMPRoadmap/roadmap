module PlansHelper

  # display the role of the user for a given plan
  def display_role(role)
    if role.creator?
      _('Owner')
    elsif role.administrator?
      _('Co-owner')
    elsif role.editor?
      _('Editor')
    elsif role.commenter?
      _('Read only')
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
    else
      return "<span>#{_('Private')}</span>" # Test Plans
    end
  end

  def visibility_tooltip(val)
    case val
    when 'organisationally_visible'
      return _('Organisation: anyone at my organisation can view.')
    when 'publicly_visible'
      return _('Public: anyone can view.')
    else
      return _('Private: restricted to me and people I invite.')
    end
  end

end
