module ProjectsHelper

  # Build variable column headings for the project list
  # --------------------------------------------------------
  def project_list_column_heading(column)
    if column.kind_of?(Array)
      heading = (column.first.kind_of?(String) ? column.first : t("helpers.project.columns.unknown"))
    
    elsif column.kind_of?(String)
      heading = column

    else
      heading = t("helpers.project.columns.unknown")
    end
    
    klass = (['name', 'description'].include?(heading) ? :dmp_th_big : :dmp_th_small)

    content_tag(:th, t("helpers.project.columns.#{heading}"), class: klass)
  end

  # Populate a variable column for the project list
  # --------------------------------------------------------
  def project_list_column_body(column, project)
    
    col = (column.kind_of?(Array) ? column[0] : column)
    
    klass, content = case col
      when 'name'
        [ "dmp_td_big", link_to(project.title, project_path(project), class: "dmp_table_link") ]
        
      when 'owner'
        user = project.owner
        
        text = if user.nil?
          "Unknown"
        elsif user == current_user
          t("helpers.me")
        else
          user.name
        end

        [ "tmp_td_small", text ]
      when 'shared'
        shared_num = project.project_groups.count - 1
        text = shared_num > 0 ? (t("helpers.yes_label") + " (with #{shared_num} people) ") : t("helpers.no_label")
        [ "dmp_td_small", text ]
      when 'last_edited'
        [ "dmp_td_small", l(project.latest_update.to_date, formats: :short) ]
      when 'description'
        [ "dmp_td_medium", (project.try(col) || "Unknown") ]
      else
        [ "dmp_td_small", (project.try(col) || "Unknown") ]
    end

    content_tag(:td, content, class: klass)
  end

  # Shows whether the user has default, template-default or custom settings
  # for the given plan.
  # --------------------------------------------------------
  def plan_settings_indicator(plan)
    plan_settings     = plan.super_settings(:export)
    template_settings = plan.project.dmptemplate.try(:settings, :export)

    key = if plan_settings.try(:value?)
      plan_settings.formatting == template_settings.formatting ? "template_formatting" : "custom_formatting"
    elsif template_settings.try(:value?)
      "template_formatting"
    else
      "default_formatting"
    end

    content_tag(:small, t("helpers.settings.plans.#{key}"))
  end

end
