module PlansHelper

  def project_list_head(column)
    klass = case column
      when 'name'  then :dmp_th_big
      when 'description' then :dmp_th_big
      else :dmp_th_small
    end

    content_tag(:th, t("helpers.project.columns.#{column}"), class: klass)
  end

  def project_list_body(column, project)
    klass, content = case column[0]
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
        [ "dmp_td_medium", (project.try(column[0]) || "Unknown") ]
      else
        [ "dmp_td_small", (project.try(column[0]) || "Unknown") ]
    end

    content_tag(:td, content, class: klass)
  end

  # Shows whether the user has default, template-default or custom settings
  # for the given plan.
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
