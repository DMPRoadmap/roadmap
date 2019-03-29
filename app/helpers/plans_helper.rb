# frozen_string_literal

module PlansHelper

  def selected_guidance_groups_for_plan(plan)
    plan.guidance_groups.ids
  end

  def all_guidance_groups_by_org_for_plan(plan)
    plan.guidance_group_options.sort.group_by(&:org)
  end

  def important_guidance_groups_for_plan(plan)
    all_ggs_grouped_by_org   = all_guidance_groups_by_org_for_plan(plan)
    selected_guidance_groups = selected_guidance_groups_for_plan(plan)

    # Important ones come first on the page - we grab the user's org's GGs and
    # "Organisation" org type GGs
    important_ggs = []

    if all_ggs_grouped_by_org.include?(current_user.org)
      important_ggs << [current_user.org, all_ggs_grouped_by_org[current_user.org]]
    end
    all_ggs_grouped_by_org.each do |org, ggs|
      if org.organisation?
        important_ggs << [org, ggs]
      end

      # If this is one of the already selected guidance groups its important!
      if !(ggs & selected_guidance_groups).empty?
        important_ggs << [org, ggs] unless important_ggs.include?([org, ggs])
      end
    end

    # Sort the rest by org name for the accordion
    important_ggs.sort_by { |org, gg| (org.nil? ? "" : org.name) }
  end

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

  def download_plan_page_title(plan, phase, hash)
    # If there is more than one phase show the plan title and phase title
    return hash[:phases].many? ? "#{plan.title} - #{phase[:title]}" : plan.title
  end

  def display_section?(customization, section, show_custom_sections)
    display = !customization
    display ||= customization && !section[:modifiable]
    display ||= customization && section[:modifiable] && show_custom_sections
    return display
  end
end
