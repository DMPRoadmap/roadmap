# frozen_string_literal: true

# Helper methods for Plans
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

  # display the role of the user for a given plan
  def display_client_role(client_role)
    if client_role.creator?
      _('Creator')
    elsif client_role.edit?
      _('Editor')
    elsif client_role.read?
      _('Read only')
    end
  end

  # display the visibility of the plan
  def display_visibility(val)
    case val
    when 'organisationally_visible'
      "<span title=\"#{visibility_tooltip(val)}\">#{_('Organisation')}</span>"
    when 'publicly_visible'
      "<span title=\"#{visibility_tooltip(val)}\">#{_('Public')}</span>"
    # --------------------------------
    # Start DMP OPIDoR Customization
    # CHANGES : Added administrator_visible visibility
    # --------------------------------
    when 'administrator_visible'
      "<span title=\"#{visibility_tooltip(val)}\">#{_('Administrator')}</span>"
    # --------------------------------
    # End DMP OPIDoR Customization
    # --------------------------------
    when 'privately_visible'
      "<span title=\"#{visibility_tooltip(val)}\">#{_('Private')}</span>"
    else
      "<span>#{_('Private')}</span>" # Test Plans
    end
  end

  def visibility_tooltip(val)
    case val
    when 'organisationally_visible'
      _('Organisation: anyone at my organisation can view.')
    when 'publicly_visible'
      _('Public: anyone can view.')
    # --------------------------------
    # Start DMP OPIDoR Customization
    # CHANGES : Added administrator_visible visibility
    # --------------------------------
    when 'administrator_visible'
      _('Administrator: visible to me, specified collaborators and administrators at my organisation.')
    # --------------------------------
    # End DMP OPIDoR Customization
    # --------------------------------
    else
      _('Private: restricted to me and people I invite.')
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

  # --------------------------------
  # Start DMP OPIDoR Customization
  # display the name of the owner of a plan
  # --------------------------------
  def display_owner(owner)
    if owner == current_user
      _('You')
    else
      owner&.name(false)
    end
  end
  # --------------------------------
  # End DMP OPIDoR Customization
  # --------------------------------
end
