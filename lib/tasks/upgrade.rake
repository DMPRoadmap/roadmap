require 'set'
namespace :upgrade do

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
end
