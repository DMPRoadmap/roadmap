namespace :bugfix do

  desc "Upgrade to 1.0"
  task v1_0_0: :environment do
    Rake::Task['bugfix:set_template_visibility'].execute
    Rake::Task['bugfix:set_org_link_defaults'].execute
    Rake::Task['bugfix:set_template_link_defaults'].execute
  end

  desc "Bug fixes for version v0.3.3"
  task v0_3_3: :environment do
    Rake::Task['bugfix:fix_question_formats'].execute
    Rake::Task['bugfix:add_missing_token_permission_types'].execute
  end

  desc "Add the missing formattype to the question_formats table"
  task fix_question_formats: :environment do
    QuestionFormat.all.each do |qf|
      case qf.title.downcase
      when 'text area'
        qf.formattype = :textarea
      when 'text field'
        qf.formattype = :textfield
      when 'radio buttons'
        qf.formattype = :radiobuttons
      when 'check box'
        qf.formattype = :checkbox
      when 'dropdown'
        qf.formattype = :dropdown
      when 'multi select box'
        qf.formattype = :multiselectbox
      when 'date'
        qf.formattype = :date
      end

      qf.save!
    end

    if QuestionFormat.find_by(formattype: :date).nil?
      QuestionFormat.create!({title: "Date", option_based: true, formattype: 6})
    end
  end

  desc "Add the missing token_permission_types"
  task add_missing_token_permission_types: :environment do
    if TokenPermissionType.find_by(token_type: 'templates').nil?
      TokenPermissionType.create!({token_type: 'templates',
                                   text_description: 'allows a user access to the templates api endpoint'})
    end
    if TokenPermissionType.find_by(token_type: 'statistics').nil?
      TokenPermissionType.create!({token_type: 'statistics',
                                   text_description: 'allows a user access to the statistics api endpoint'})
    end
  end

  desc "Set all funder templates (and the default template) to 'public' visibility and all others to 'organisational'"
  task set_template_visibility: :environment do
    funders = Org.funders.pluck(:id)
    Template.update_all visibility: Template.visibilities[:organisationally_visible]
    Template.where(org_id: funders).update_all visibility: Template.visibilities[:publicly_visible]
    Template.default.update visibility: Template.visibilities[:publicly_visible]
  end

  desc "Set all orgs.links defaults"
  task set_org_link_defaults: :environment do
    Org.all.each do |org|
      begin
        org.update_attributes(links: {"org":[]})
      rescue Dragonfly::Job::Fetch::NotFound
        puts "Unable to set link defaults for Org #{org.id} - #{org.name} due to a missing logo file. Please update manually: `UPDATE orgs set links = '{\"org\":[]}' WHERE id = #{org.id};`"
      end
    end
  end

  desc "Set all template.links defaults"
  task set_template_link_defaults: :environment do
    Template.all.each do |template|
      template.update_attributes(links: {"funder":[],"sample_plan":[]})
    end
  end

  desc "Sets completed for plans whose no. questions matches no. valid answers"
  task set_plan_complete: :environment do
    Plan.all.each do |p|
      if p.no_questions_matches_no_answers?
        p.update_column(:complete, true) # Avoids updating the column updated_at
      end
    end
  end

  desc "Allow Statistics API Usage for Org Admin Users"
  task stats_api_org_admin: :environment do
    Rake::Task['bugfix:add_missing_token_permission_types'].execute
    orgs = Org.where(is_other: nil)
    orgs.each do |org|
      org.grant_api!(TokenPermissionType::STATISTICS)
    end
    users = User.joins(:perms).where("org_id IN (?) AND (api_token IS NULL OR api_token = '')", orgs.collect(&:id))
    users.each do |user|
      if user.can_org_admin?
        # Generate the tokens directly instead of via the User.keep_or_generate_token! method so that we do not spam users!!
        user.api_token = loop do
          random_token = SecureRandom.urlsafe_base64(nil, false)
          break random_token unless User.exists?(api_token: random_token)
        end
        user.save!
      end
    end
  end
end
