require 'set'
namespace :upgrade do

  desc "Upgrade to v2.2.0"
  task v2_2_0: :environment do
    Rake::Task["upgrade:add_new_identifier_schemes"].execute
    Rake::Task["upgrade:update_shibboleth_description"].execute
    Rake::Task["upgrade:contextualize_identifier_schemes"].execute
    Rake::Task["upgrade:convert_user_identifiers"].execute
    Rake::Task["upgrade:convert_org_identifiers"].execute
    Rake::Task["upgrade:default_orgs_to_managed"].execute
    Rake::Task["upgrade:migrate_other_organisation_to_org"].execute
    Rake::Task["upgrade:retrieve_ror_fundref_ids"].execute
  end

  desc "Upgrade to v2.1.3"
  task v2_1_3: :environment do
    Rake::Task['upgrade:fill_blank_plan_identifiers'].execute
    Rake::Task["upgrade:add_reviewer_perm"].execute
    Rake::Task["upgrade:add_reviewer_to_existing_admin_perms"].execute
    Rake::Task["upgrade:migrate_reviewer_roles"].execute
  end

  desc "Upgrade to v2.1.2:"
  task v2_1_2: :environment do
    Rake::Task["upgrade:add_date_question_format"].execute
  end

  desc "Upgrade to v2.1.0:"
  task v2_1_0: :environment do
    Rake::Task["data_cleanup:deactivate_orphaned_plans"].execute
  end

  desc "Upgrade to v2.0.0: Part 1"
  task v2_0_0_part_1: :environment do
    Rake::Task['upgrade:add_default_values_v2_0_0'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['data_cleanup:find_known_invalidations'].execute
    puts "If any invalid records were reported above you will need to correct them before running part 2."
  end

  desc "Upgrade to v2.0.0: Part 2"
  task v2_0_0_part_2: :environment do
    Rake::Task['data_cleanup:clean_invalid_records'].execute
    Rake::Task['upgrade:add_versioning_id_to_templates'].execute
    Rake::Task['upgrade:normalize_language_formats'].execute
    Rake::Task['stat:build'].execute
  end

  desc "Upgrade to v1.1.2"
  task v1_1_2: :environment do
    Rake::Task['upgrade:check_org_contact_emails'].execute
    Rake::Task['upgrade:check_for_guidance_multiple_themes'].execute
    Rake::Task['upgrade:remove_admin_preferences'].execute
    Rake::Task['upgrade:add_other_org'].execute
  end

  desc "Upgrade to 1.0"
  task v1_0_0: :environment do
    Rake::Task['upgrade:set_template_visibility'].execute
    Rake::Task['upgrade:set_org_links_defaults'].execute
    Rake::Task['upgrade:set_template_links_defaults'].execute
    Rake::Task['upgrade:set_plan_complete'].execute
    Rake::Task['upgrade:stats_api_org_admin'].execute
  end

  desc "Bug fixes for version v0.3.3"
  task v0_3_3: :environment do
    Rake::Task['upgrade:fix_question_formats'].execute
    Rake::Task['upgrade:add_missing_token_permission_types'].execute
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

    if QuestionFormat.find_by(formattype: QuestionFormat.formattypes[:date]).nil?
      QuestionFormat.create!({ title: "Date", option_based: false, formattype: QuestionFormat.formattypes[:date] })
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
    funders = Org.funder.pluck(:id)
    Template.update_all(visibility: Template.visibilities[:organisationally_visible])
    Template.where(org_id: funders).update_all(visibility: Template.visibilities[:publicly_visible])
    Template.default.update(visibility: Template.visibilities[:publicly_visible])
  end

  desc "Set all orgs.links defaults"
  task set_org_links_defaults: :environment do
    Org.update_all(links: { 'org': [] })
  end

  desc "Set all template.links defaults"
  task set_template_links_defaults: :environment do
    Template.update_all(links: {'funder':[],'sample_plan':[]})
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
    Rake::Task['upgrade:add_missing_token_permission_types'].execute
    orgs = Org.where(is_other: false).select(:id)
    orgs.each do |org|
      org.grant_api!(TokenPermissionType.where(token_type: 'statistics'))
    end
    users = User.joins(:perms).where(org_id: orgs).where(api_token: [nil, ''])
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


  desc "Remove Duplicate Answers"
  task remove_duplicate_answers: :environment do
    ## Concat Duplicate Answers
    ActiveRecord::Base.transaction do
      plan_ids = ActiveRecord::Base.connection.select_all("SELECT a1.plan_id as plan_id FROM Answers a1 INNER JOIN Answers a2 ON a1.plan_id = a2.plan_id AND a1.question_id = a2.question_id WHERE a1.id > a2.id" ).to_a.map{|h| h["plan_id"]}.uniq
      plans = Plan.where(id: plan_ids)
      plans.each do |plan|
        plan.answers.pluck(:question_id).uniq.each do |question_id|
          answers = Answer.where(plan_id: plan.id, question_id:  question_id).order(:updated_at)
          if answers.length > 1 # Duplicates found
            puts "found duplicate for plan:#{plan.id}\tquestion:#{question_id} \n\tanswers:[#{answers.map{|answer| answer.id}}]"
            new_answer = Answer.new
            new_answer.user_id = answers.last.user_id
            new_answer.plan_id = plan.id
            new_answer.question_id = question_id
            new_answer.created_at = answers.last.created_at
            num_text = 0
            qf = answers.last.question.question_format
            puts "\tquestion format #{qf.title}"
            if qf.dropdown?
              new_answer.question_options << answers.last.question_options.first
              puts "\t adding option answers.last.question_options.first.text" unless answers.last.question_options.first.blank?
            end
            answers.reverse.each do |answer|
              if num_text == 0 && answer.text.present? # case first present text
                new_answer.text = answer.text
                num_text += 1
              end
              if num_text == 1 && answer.text.present?
                text = "<p><strong>ANSWER SAVED TWICE - REQUIRES MERGING</strong></p>"
                text += new_answer.text
                new_answer.text = text + "<p><strong>-------------</strong></p>" + answer.text
              end
              new_answer.save
              new_answer.reload
              answer.notes.each do |note|
                note.answer_id = new_answer.id
                note.save
              end
              answer.question_options.each do |op|
                unless qf.dropdown?
                  new_answer.question_options << op unless new_answer.question_options.any? {|aop| aop.id == op.id}
                  puts "\t adding option #{op.text}"
                end
              end
              answer.destroy
            end
            new_answer.save
            puts "\tsaved new answer with text:\n#{new_answer.text}"
          end
        end
      end
    end
  end

  desc "Remove deprecated themes"
  task theme_delete_deprecated: :environment do
    if t = Theme.find_by(title:'Project Description') then t.destroy end
    if t = Theme.find_by(title:'Project Name') then t.destroy end
    if t = Theme.find_by(title:'ID') then t.destroy end
    if t = Theme.find_by(title:'PI / Researcher') then t.destroy end
  end

  desc "Create new Theme list"
  task theme_new_themes: :environment do
    ["Data description", "Data collection", "Metadata & documentation", "Storage & security",
     "Preservation", "Data sharing", "Related policies", "Data format", "Data volume",
     "Ethics & privacy", "Intellectual Property Rights", "Data repository", "Roles & responsibilities",
     "Budget"].each do |t|
      Theme.create(title: t)
    end
  end

  desc "Transform existing themes and their associations into new theme list"
  task theme_transform: :environment do
    ActiveRecord::Base.transaction do
      [
      {'Budget':'Resourcing'},
      {'Data collection':'Data Capture Methods'},
      {'Data collection':'Data Quality'},
      {'Data description':'Data Description'},
      {'Data description':'Data Type'},
      {'Data description':'Existing Data'},
      {'Data description':'Relationship to Existing Data'},
      {'Data format':'Data Format'},
      {'Data repository':'Data Repository'},
      {'Data sharing':'Expected Reuse'},
      {'Data sharing':'Managed Access Procedures'},
      {'Data sharing':'Method For Data Sharing'},
      {'Data sharing':'Restrictions on Sharing'},
      {'Data sharing':'Timeframe For Data Sharing'},
      {'Data volume':'Data Volumes'},
      {'Ethics & privacy':'Ethical Issues'},
      {'Intellectual Property Rights':'IPR Ownership and Licencing'},
      {'Metadata & documentation':'Discovery by Users'},
      {'Metadata & documentation':'Documentation'},
      {'Metadata & documentation':'Metadata '},  # there may be a whitespace here!
      {'Preservation':'Data Selection'},
      {'Preservation':'Period of Preservation'},
      {'Preservation':'Preservation Plan'},
      {'Related policies':'Related Policies'},
      {'Roles & responsibilities':'Responsibilities'},
      {'Storage & security':'Data Security'},
      {'Storage & security':'Storage and Backup'},
      ].each do |pair|
        themeto   = Theme.find_by(title: pair.keys[0].to_s)
        themefrom = Theme.find_by(title: pair.values[0])
        Guidance.joins(:themes).where('themes.title' => themefrom.title).each do |gui|
          gui.themes.delete(themefrom)
          gui.themes << themeto
        end
        Question.joins(:themes).where('themes.title' => themefrom.title).each do |q|
          q.themes.delete(themefrom)
          q.themes << themeto
        end
      end
    end
  end

  desc "Delete migrated themes and their associations"
  task theme_remove_migrated: :environment do
    ActiveRecord::Base.transaction do
      ["Data Type", "Existing Data", "Relationship to Existing Data", "Data Quality", "Documentation",
      "Discovery by Users", "Data Security", "Data Selection", "Period of Preservation",
      "Expected Reuse", "Timeframe For Data Sharing", "Restrictions on Sharing",
      "Managed Access Procedures", "Related Policies", "Data Description", "Data Volumes",
      "Data Format", "Data Capture Methods", "Metadata ", "Ethical Issues",
      "IPR Ownership and Licencing", "Storage and Backup", "Preservation Plan", "Data Repository",
      "Method For Data Sharing", "Responsibilities", "Resourcing"].each do |t|
        if deltheme = Theme.find_by(title: t) then deltheme.destroy end
      end
    end
  end

  desc "Deduplicate multiple associations resulting from Theme merges"
  task theme_deduplicate_questions: :environment do
    ActiveRecord::Base.transaction do
      Question.all.each do |q|
        themelist = []
        if q.themes.present?
          q.themes.each do |qt|
            q.themes.delete(qt)
            q.themes << qt
          end
        end
      end
    end
  end

  ############# Make sure there are no guidances with multiple themes before this step!! #############
  desc "Concatenate Guidance which refers to the same Theme as a result of merges"
  task single_guidance_for_theme: :environment do
    ActiveRecord::Base.transaction do
      allthemes = Theme.all
      GuidanceGroup.all.each do |group|
          if group.guidances.present?
              allthemes.each do |theme|
                  themeguidances = group.guidances.joins(:themes).where('themes.id = ?', theme.id)
                  if themeguidances.present? && themeguidances.length >= 2
                      themeguidances.drop(1).each do |guidance|
                          themeguidances.first.text += '<p>——</p>' + guidance.text
                          guidance.destroy
                      end #themeguidances loop
                      themeguidances.first.save
                  end
              end #allthemes loop
          end
      end #GuidanceGroup loop
    end
  end

  desc "Remove duplicated non customised template versions"
  task remove_duplicated_non_customised_template_versions: :environment do
    templates = Template
      .select(:id, :family_id, :version, :updated_at)
      .group(:family_id, :version, :id)
      .order(family_id: :asc, version: :asc, updated_at: :desc)

    current_family_id = nil
    unique_versions = Set.new
    duplicates = []
    templates.each do |template|
      if current_family_id != template.family_id
        current_family_id = template.family_id
        unique_versions = Set.new
      end
      if unique_versions.add?(template.version).nil?
        duplicates << template
      end
    end
    current_family_id = nil
    version_counter = nil
    duplicates.each do |template|
      if current_family_id != template.family_id
        current_family_id = template.family_id
        version_counter = nil
      end
      num_plans = Plan.where(template_id: template.id).count
      if num_plans > 0
        version_counter = version_counter.nil? ? -1 : version_counter - 1
        unsaved_template = Template.find(template.id)
        unsaved_template.version = version_counter
        if Template.exists?(customization_of: template.family_id)
          puts "template with id: #{template.id} has NOT been ARCHIVED since it had customised templates"
        else
          puts "template with id: #{template.id} has been ARCHIVED since it had plans associated but no customised templates"
          unsaved_template.archived = true
        end
        unsaved_template.save!
      else
        Template.destroy(template.id)
        puts "template with id: #{template.id} has been REMOVED since it had no plans associated"
      end
    end
    puts "remove_duplicated_non_customised_template_versions DONE"
  end
  desc "Remove duplicated customised template versions"
  task remove_duplicated_customised_template_versions: :environment do
    templates = Template
      .select(:id, :customization_of, :version, :org_id, :updated_at)
      .where('customization_of IS NOT NULL')
      .group(:customization_of, :org_id, :version, :id)
      .order(customization_of: :asc, org_id: :asc, version: :asc, updated_at: :desc)
    generate_compound_key = lambda{ |customization_of, org_id| return "#{customization_of}_#{org_id}" }
    current = nil
    unique_versions = Set.new
    duplicates = []
    templates.each do |template|
      key = generate_compound_key.call(template.customization_of, template.org_id)
      if current != key
        current = key
        unique_versions = Set.new
      end
      if unique_versions.add?(template.version).nil?
        duplicates << template
      end
    end
    current = nil
    version_counter = nil
    duplicates.each do |template|
      key = generate_compound_key.call(template.customization_of, template.org_id)
      if current != key
        current = key
        version_counter = nil
      end
      num_plans = Plan.where(template_id: template.id).count
      if num_plans > 0
        version_counter = version_counter.nil? ? -1 : version_counter - 1
        unsaved_template = Template.find(template.id)
        unsaved_template.version = version_counter
        unsaved_template.archived = true
        unsaved_template.save!
        puts "template with id: #{template.id} has been ARCHIVED since it had plans associated"
      else
        Template.destroy(template.id)
        puts "template with id: #{template.id} has been REMOVED since it has no plans associated"
      end
    end
    puts "remove_duplicated_customised_template_versions DONE"
  end
  desc "Remove duplicated template versions"
  task remove_duplicated_template_versions: :environment do
    Rake::Task['upgrade:remove_duplicated_non_customised_template_versions'].execute
    Rake::Task['upgrade:remove_duplicated_customised_template_versions'].execute
  end

  desc "Org.contact_email is now required, sets any nil values to the helpdesk email defined in branding.yml"
  task check_org_contact_emails: :environment do
    branding = YAML.load(File.open('./config/branding.yml'))
    if branding.is_a?(Hash) &&
        branding['defaults'].present? &&
        branding['defaults']['organisation'].present? &&
        branding['defaults']['organisation']['name'].present?
        branding['defaults']['organisation']['helpdesk_email'].present?
      email = branding['defaults']['organisation']['helpdesk_email']
      name = "#{branding['defaults']['organisation']['name']} helpdesk"

      puts "Searching for Orgs with an undefined contact_email ..."
      Org.where("contact_email IS NULL OR contact_email = ''").each do |org|
        puts "  Setting contact_email to #{email} for #{org.name}"
        org.update_attributes(contact_email: email, contact_name: name)
      end
    else
      puts "No helpdesk_email and/or name found in your config/branding.yml. Please add them under the defaults -> organisation section"
      puts "For example:"
      puts "  defaults: &defaults"
      puts "    organisation:"
      puts "      name: 'Curation Center'"
      puts "      helpdesk_email: 'helpdesk@example.org'"
    end
    puts "Search complete"
    puts ""
  end

  desc "The system now only allows for one theme selection per guidance, so check for violations"
  task check_for_guidance_multiple_themes: :environment do
    puts "Searching for guidance with multiple theme selections (you will need to manually reconcile these records) ..."
    ids = Guidance.select('guidances.id, count(themes.id) theme_count').
            joins(:themes).group('guidances.id').
            having('count(themes.id) > 1').pluck('guidances.id')

    GuidanceGroup.joins(:guidances).includes(:org).where('guidances.id IN (?)', ids).
            distinct.order('orgs.name, guidance_groups.name').each do |grp|
      puts "  #{grp.org.name} - Guidance group, '#{grp.name}', has guidance with multiple themes"
    end
    puts "Search complete"
    puts ""
  end

  desc "Remove admin preferences"
  task remove_admin_preferences: :environment do
    Pref.all.each do |p|
      if p.settings.present?
        if p.settings['email'].present?
          if p.settings['email']['admin'].present?
            p.settings['email'].delete('admin')
            p.save!
          end
        end
      end
    end
  end

  desc "Add the 'other' org if it is not present."
  task add_other_org: :environment do
    puts "Checking for existence of an 'Other' org. Unaffiliated users should be affiliated with this org"

    # Get the helpdesk email from the branding YAML
    branding = YAML.load(File.open('./config/branding.yml'))
    if branding.present? && branding['defaults'].present? && branding['defaults']['organisation'].present? && branding['defaults']['organisation']['helpdesk_email'].present?
      email = branding['defaults']['organisation']['helpdesk_email']
      name = branding['defaults']['organisation']['name'].present? ? "#{branding['defaults']['organisation']['name']} helpdesk" : 'Helpdesk'
    else
      email = 'other.organisation@example.org'
      name = 'Helpdesk'
    end

    other_org = Org.find_by(is_other: true)
    if other_org.present?
      puts "Found the 'Other' org (is_other == true)"
    else
      puts "Could not find the 'Other' org (is_other == true), adding 'Other' org"
      other_org = Org.create!({
        name: 'Other Organisation',
        abbreviation: 'OTHER',
        org_type: Org.org_type_values_for(:organisation).min,
        contact_email: email,
        contact_name: name,
        links: {"org": []},
        is_other: true,
      })
    end

    unaffiliated = User.where(org_id: nil)
    unless unaffiliated.empty?
      puts "The following users are not associated with an org. Assigning them to the 'Other' org."
      puts unaffiliated.collect(&:email).join(', ')
      unaffiliated.update_all(org_id: other_org.id)
    end
  end

  desc "Apply default column values for v2.0.0"
  task :add_default_values_v2_0_0 => :environment do
    results = GuidanceGroup.where(optional_subset: nil)
    puts "Found #{results.length} GuidanceGroups with a null optional_subset ... set values to false"
    results.update_all(optional_subset: false)

    results = GuidanceGroup.where(published: nil)
    puts "Found #{results.length} GuidanceGroups with a null published ... set values to false"
    results.update_all(published: false)

    results = Note.where(archived: nil)
    puts "Found #{results.length} Notes with a null archived ... set values to false"
    results.update_all(archived: false)

    results = Org.where(is_other: nil)
    puts "Found #{results.length} Orgs with a null is_other ... set values to false"
    results.update_all(is_other: false)
  end

  desc "Add verisoning_id to published Templates"
  task :add_versioning_id_to_templates => :environment do
    safe_require 'text'
    safe_require 'progress_bar'

    template_count = Template.latest_version.where(customization_of: nil)
                             .includes(phases: { sections: { questions: :annotations }})
                             .count
    bar = ProgressBar.new(template_count)


    # Remove attr_readonly restrictions form these models
    Phase.attr_readonly.delete('versionable_id')
    Section.attr_readonly.delete('versionable_id')
    Question.attr_readonly.delete('versionable_id')
    Annotation.attr_readonly.delete('versionable_id')


    # Get each of the funder templates...
    Template.latest_version.where(customization_of: nil)
            .includes(phases: { sections: { questions: :annotations }})
            .each do |funder_template|

      bar.increment!(1)

      Rails.logger.info "Updating versionable_id for Template: #{funder_template.id}"

      funder_template.phases.each do |funder_phase|
        Rails.logger.info "Updating versionable_id for Phase: #{funder_phase.id}"
        funder_phase.update! versionable_id: SecureRandom.uuid

        Phase.joins(:template)
             .where(templates: { customization_of: funder_template.family_id })
             .where(number: funder_phase.number).each do |phase|

          if fuzzy_match?(phase.title, funder_phase.title)
            phase.update! versionable_id: funder_phase.versionable_id
          end
        end

        funder_phase.sections.each do |funder_section|
          Rails.logger.info "Updating versionable_id for Section: #{funder_section.id}"
          funder_section.update! versionable_id: SecureRandom.uuid

          Section.joins(:template).where(templates: {
            customization_of: funder_template.family_id
            }).each do |section|

            # Prefix the match text with the number. This will make it easier to match
            # Sections where the number hasn't changed
            text_a = "#{section.number} - #{section.description}"
            text_b = "#{funder_section.number} - #{funder_section.description}"
            if fuzzy_match?(text_a, text_b)
              section.update! versionable_id: funder_section.versionable_id
            end
          end

          funder_section.questions.each do |funder_question|
            Rails.logger.info "Updating versionable_id for Question: #{funder_question.id}"

            funder_question.update! versionable_id: SecureRandom.uuid

            Question.joins(:template).where(templates: {
              customization_of: funder_template.family_id
              }).each do |question|

              # Prefix the match text with the number. This will make it easier to match
              # Questions where the number hasn't changed
              text_a = "#{question.number} - #{question.text}"
              text_b = "#{funder_question.number} - #{funder_question.text}"

              if fuzzy_match?(text_a, text_b)
                question.update! versionable_id: funder_question.versionable_id
              end
            end

            funder_question.annotations.each do |funder_annotation|
              Rails.logger.info "Updating versionable_id for Annotation: #{funder_annotation.id}"

              funder_annotation.update! versionable_id: SecureRandom.uuid

              Annotation.joins(:template).where(templates: {
                customization_of: funder_template.family_id,
              }).where(type: funder_annotation.type).each do |ann|

                if fuzzy_match?(ann.text, funder_annotation.text)
                  ann.update! versionable_id: funder_annotation.versionable_id
                end
              end
            end
          end
        end
      end
    end

    # Add versionable_id to any customized Sections...
    Section.joins(:template)
           .includes(questions: :annotations)
           .where(templates: { id: Template.latest_version.ids })
           .where(versionable_id: nil, modifiable: true).each do |section|

      section.update! versionable_id: SecureRandom.uuid

      section.questions.each do |question|
        question.update! versionable_id: SecureRandom.uuid
        question.annotations.each do |annotation|
          annotation.update! versionable_id: SecureRandom.uuid
        end
      end
    end
  end

  desc "Update Language abbreviations to use ISO format"
  task :normalize_language_formats => :environment do
    Language.all.each do |language|
      language.update(abbreviation: LocaleFormatter.new(language.abbreviation))
    end
    Template.all.each do |template|
      next if template.locale.blank?
      template.update(locale: LocaleFormatter.new(template.locale))
    end
    Theme.all.each do |theme|
      next if theme.locale.blank?
      theme.update(locale: LocaleFormatter.new(theme.locale))
    end
  end

  desc "Adds the Date question format"
  task :add_date_question_format => :environment do
    unless QuestionFormat.id_for(QuestionFormat.formattypes[:date]).present?
      QuestionFormat.create(
        title: "Date field",
        description: "Date field format",
        option_based: false,
        formattype: QuestionFormat.formattypes[:date]
      )
    end
  end


  desc "Fill blank or nil plan identifiers with plan_id"
  task fill_blank_plan_identifiers: :environment do
    Plan.where(identifier: ["",nil]).update_all('identifier = id')
  end

  desc "Adds a new permission for plan reviewers"
  task add_reviewer_perm: :environment do
    perm_name = 'review_org_plans'
    unless Perm.find_by(name: perm_name).present?
      Perm.create(name: perm_name)
    end
  end

  desc "adds the new reviewer perm to all existing admin perms"
  task add_reviewer_to_existing_admin_perms: :environment do
    Perm.change_org_details.users.each do |u|
      u.perms << Perm.review_plans
    end
  end

  desc "remove the old reviewer roles and ensure these are marked feedback-enabled"
  task migrate_reviewer_roles: :environment do
    # remove all roles with nil plan_id
    Role.reviewer.where(plan_id: nil).destroy_all
    # Pluck all other plan_ids
    review_plan_ids = Role.reviewer.pluck(:plan_id).uniq
    Plan.where(id: review_plan_ids).update_all(feedback_requested: true)
    Role.reviewer.destroy_all
  end

  desc "add the ROR and Fundref identifier schemes"
  task add_new_identifier_schemes: :environment do
    unless IdentifierScheme.where(name: "fundref").any?
      IdentifierScheme.create(
        name: "fundref",
        description: "Crossref Funder Registry (FundRef)",
        active: true
      )
    end
    unless IdentifierScheme.where(name: "ror").any?
      IdentifierScheme.create(
        name: "ror",
        description: "Research Organization Registry (ROR)",
        active: true
      )
    end
  end

  desc "update the Shibboleth scheme description"
  task update_shibboleth_description: :environment do
    scheme = IdentifierScheme.where(name: "shibboleth")
    if scheme.any?
      scheme.first.update(description: "Institutional Sign In (Shibboleth)")
    end
  end

  desc "Contextualize the Identifier Schemes (e.g. which ones are for orgs, etc."
  task contextualize_identifier_schemes: :environment do
    # Identifier schemes for multiple uses
    shib = IdentifierScheme.find_or_initialize_by(name: "shibboleth")
    shib.for_users = true
    shib.for_orgs = true
    shib.for_authentication = true
    shib.save

    orcid = IdentifierScheme.find_or_initialize_by(name: "orcid")
    orcid.for_users = true
    orcid.for_contributors = true
    orcid.for_authentication = true
    orcid.identifier_prefix = "https://orcid.org/"
    orcid.save

    # Org identifier schemes
    ror = IdentifierScheme.find_or_initialize_by(name: "ror")
    ror.for_orgs = true
    ror.identifier_prefix = "https://ror.org/"
    ror.save

    fundref = IdentifierScheme.find_or_initialize_by(name: "fundref")
    fundref.for_orgs = true
    fundref.identifier_prefix = "https://api.crossref.org/funders/"
    fundref.save
  end

  desc "migrate the old user_identifiers over to the polymorphic identifiers table"
  task convert_user_identifiers: :environment do
    p "Transferring existing user_identifiers over to the identifiers table"
    p "this may take in excess of 30 minutes depending on the size of your users table ..."
    UserIdentifier.joins(:user, :identifier_scheme)
                  .includes(:user, :identifier_scheme).all.each do |ui|

      ui.user.identifiers << Identifier.new(
        identifier_scheme: ui.identifier_scheme,
        value: ui.identifier,
        #type: (ui.identifier_scheme.name == "orcid" ? "url" : "other"),
        attrs: {}.to_json
      )
    end
  end

  desc "migrate the old org_identifiers over to the polymorphic identifiers table"
  task convert_org_identifiers: :environment do
    p "Transferring existing org_identifiers over to the identifiers table"
    p "please wait ..."
    OrgIdentifier.joins(:org, :identifier_scheme)
                 .includes(:org, :identifier_scheme).all.each do |ui|

      val = ui.identifier
      val = "https://orcid.org/#{val}" if ui.identifier_scheme.name == "orcid" && !val.starts_with?("http")

      ui.org.identifiers << Identifier.new(
        identifier_scheme: ui.identifier_scheme,
        value: val,
        # type: (ui.identifier_scheme.name == "orcid" ? "url" : "other"),
        attrs: ui.attrs
      )
    end
  end

  desc "Sets the new managed flag for all existing Orgs to managed = true"
  task default_orgs_to_managed: :environment do
    Org.all.update_all(managed: true)
  end

  desc "Attempts to migrate other_organisation entries to Orgs"
  task migrate_other_organisation_to_org: :environment do
    names = User.all.where.not(other_organisation: nil)
                 .pluck(:other_organisation).uniq
    names.each do |name|
      # Skip any blank names
      next if name.gsub(/\s/, "").blank?

      matches = OrgSelection::SearchService.search_locally(search_term: name)

      # If any matches were found then we will use that as the Org
      org = matches.first if matches.any?
      p "Found matching org: search: '#{name}' => '#{org[:name]}'" if org.present?

      # Otherwise create the Org
      org = Org.create(name: name, managed: false, is_other: false) if matches.empty?
      p "Created new org: search: '#{name}'" if org.present?
      next unless org.present? && org.is_a?(Org)

      # Attach all users with that other_organisation to the Org
      User.where(other_organisation: name).update_all(org_id: org.id)
    end
  end

  desc "retrieves ROR ids for each of the Orgs defined in the database"
  task retrieve_ror_fundref_ids: :environment do
    ror = IdentifierScheme.find_by(name: "ror")
    fundref = IdentifierScheme.find_by(name: "fundref")

    out = CSV.generate do |csv|
      csv << %w[org_id org_name ror_name ror_id fundref_id]

      if ExternalApis::RorService.ping
        p "Scanning ROR for each of your existing Orgs"
        p "The results will be written to tmp/ror_fundref_ids.csv to facilitate review and any corrections that may need to be made."
        p "The CSV file contains the Org name stored in your DB next to the ROR org name that was matched. Use these 2 values to determine if the match was valid."
        p "You can use the ROR search page to find the correct match for any organizations that need to be corrected: https://ror.org/search"
        p ""
        Org.includes(identifiers: :identifier_scheme)
           .where(is_other: false).order(:name).each do |org|

          # If the Org already has a ROR identifier skip it
          next if org.identifiers.select { |id| id.identifier_scheme_id == ror.id }.any?

          # The abbreviation sometimes causes weird results so strip it off
          # in this instance
          org_name = org.name.gsub(" (#{org.abbreviation})", "")
          rslts = OrgSelection::SearchService.search_externally(search_term: org_name)
          next unless rslts.any?

          # Just use the first match that contains the search term
          rslt = rslts.select { |rslt| rslt[:weight] <= 1 }.first
          next unless rslt.present?

          ror_id = rslt[:ror]
          fundref_id = rslt[:fundref]

          if ror_id.present?
            ror_ident = Identifier.find_or_initialize_by(identifiable: org,
                                                         identifier_scheme: ror)
            ror_ident.value = "#{ror.identifier_prefix}#{ror_id}"
            ror_ident.save
            p "    #{org.name} -> ROR: #{ror_ident.value}, #{rslt[:name]}"
          end
          if fundref_id.present?
            fr_ident = Identifier.find_or_initialize_by(identifiable: org,
                                                        identifier_scheme: fundref)
            fr_ident.value = "#{fundref.identifier_prefix}#{fundref_id}"
            fr_ident.save
            p "    #{org.name} -> FUNDRF: #{fr_ident.value}, #{rslt[:name]}"
          end

          if ror_id.present? || fundref_id.present?
            csv << [org.id, org.name, rslt[:name], ror_ident&.value, fr_ident&.value]
          end
        end
      else
        p "ROR appears to be offline or your configuration is invalid. Heartbeat check failed. Refer to the log for more information."
      end
    end

    if out.present?
      file = File.open("tmp/ror_fundref_ids.csv", "w")
      file.puts out
      file.close
    end
  end

  private

  def fuzzy_match?(text_a, text_b, min = 3)
    Text::Levenshtein.distance(text_a, text_b) <= min
  end

  def safe_require(libname)
    begin
      require libname
    rescue LoadError
      puts "Please install the #{libname} gem locally and try again:
              gem install #{libname}"
      exit 1
    end
  end

end
