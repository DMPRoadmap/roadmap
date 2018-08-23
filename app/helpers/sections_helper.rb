# frozen_string_literal: true

module SectionsHelper

  # HREF attribute value for headers in the section partials. If the section
  # is modifiable, returns the section path, otherwise the edit section path.
  #
  # section  - The section to return a URL for
  # phase    - The phase that section belongs
  # template - The template that phase belongs to
  #
  # Returns String
  def header_path_for_section(section, phase, template)
    if section.modifiable?
      edit_org_admin_template_phase_section_path(template_id: template.id,
                                                 phase_id: phase.id,
                                                 id: section.id)
    else
      org_admin_template_phase_section_path(template_id: template.id,
                                            phase_id: phase.id,
                                            id: section.id)
    end
  end

  def draggable_for_section?(section)
    section.template.latest? && section.modifiable?
  end

end
