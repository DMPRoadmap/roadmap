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


end
