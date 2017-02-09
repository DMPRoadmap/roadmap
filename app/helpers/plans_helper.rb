module PlansHelper

  # Build variable column headings for the project list
  # --------------------------------------------------------
  def plan_list_column_heading(column)
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
  def plan_list_column_body(column, plan)
    
    col = (column.kind_of?(Array) ? column[0] : column)
    
    klass, content = case col
      when 'name'
        [ "dmp_td_big", link_to(plan.title, plan_path(I18n.locale, plan), class: "dmp_table_link") ]
        
      when 'owner'
        user = plan.owner
        
        text = if user.nil?
          t("helpers.project.columns.unknown")
        elsif user == current_user
          t("helpers.me")
        else
          user.name
        end

        [ "tmp_td_small", text ]
      when 'shared'
        shared_num = plan.users.count - 1
        text = shared_num > 0 ? (t("helpers.yes_label") + " (with #{shared_num} people) ") : t("helpers.no_label")
        [ "dmp_td_small", text ]
      when 'visibility'
        ["dmp_td_small", (plan.visibility.nil? ? I18n.t("helpers.project.visibilities.labels.organisationally_visible") : I18n.t("helpers.project.visibilities.labels.#{plan.visibility}"))]
      when 'last_edited'
        [ "dmp_td_small", l(plan.latest_update.to_date, formats: :short) ]
      when 'description'
        [ "dmp_td_medium", (plan.try(col) || t("helpers.settings.unknown")) ]
      when 'non_link_name'
        [ "dmp_td_big", plan.title ]
      when 'template'
        ["dmp_td_big", plan.template.title]
      when 'organisation'
        ["dmp_td_medium", (plan.owner.org.nil? ? t("helpers.settings.unknown") : plan.owner.org.name) ]
      else
        [ "dmp_td_small", (plan.try(col) || t("helpers.settings.unknown")) ]
    end

    content_tag(:td, content, class: klass)
  end

  # Shows whether the user has default, template-default or custom settings
  # for the given plan.
  # --------------------------------------------------------
  def plan_settings_indicator(plan)
    plan_settings     = plan.super_settings(:export)
    template_settings = plan.template.try(:settings, :export)

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
