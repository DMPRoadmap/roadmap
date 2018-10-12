require "data_cleanup"

namespace :data_cleanup do

  desc "Check each record on the DB is valid and report"
  task :find_invalid_records => :environment do
    DataCleanup.logger.info("\n== Finding invalid records =======================\n")
    models.each do |model|
      DataCleanup::ModelCheck.new(model).call
    end
    DataCleanup::Reporting.prepare!
    DataCleanup::Reporting.report
  end

  desc "Clean invalid records on the database"
  task :clean_invalid_records => :environment do
    DataCleanup.logger.info("\n== Cleaning invalid records =======================\n")
    Dir[rule_paths].each do |rule_path|
      load rule_path
      klass_name = rule_path.split("rules/").last.gsub(".rb", '').classify
      model_name = klass_name.split("::").first
      opt, models = ARGV[1].to_s.split("=")
      if opt.present? && opt =='INCLUDE'
        next unless model_name.in?(models.split(","))
      elsif opt.present? && opt =='EXCLUDE'
        next if model_name.in?(models.split(","))
      elsif opt.blank?
        # :noop:
      else
        raise ArgumentError, "Unknown option: #{opt}"
      end
      rule_class = DataCleanup::Rules.const_get(klass_name)
      rule       = rule_class.new
      puts rule.description
      rule.call
    end
  end

  desc "Check that each of the known type of invalidation is fixed."
  task :find_known_invalidations => :environment do
    ## Annotation

    # Find with blank question
    results = Annotation.joins("LEFT OUTER JOIN questions ON questions.id = annotations.question_id")
                        .where(questions: { id: nil })
    report_known_invalidations(results, "Annotation", "missing question record")

    # Find with blank org
    results = Annotation.joins("LEFT OUTER JOIN orgs ON orgs.id = annotations.org_id")
                        .where(orgs: { id: nil })
    report_known_invalidations(results, "Annotation", "missing org record")

    # Find with blank text
    results = Annotation.where(text: [nil, ""])
    report_known_invalidations(results, "Annotation", "text is blank")

    # Find with duplicate type
    results = Annotation.group(:question_id, :type, :org_id)
                .count
                .select { |k,v| v > 1 }
    report_known_invalidations(results, "Annotation", "type is a duplicate")

    ## Answer

    # Fix blank plan
    results = Answer.joins("LEFT OUTER JOIN plans ON plans.id = answers.plan_id")
                    .where(plans: { id: nil })
    report_known_invalidations(results, "Answer", "missing plan record")

    # Fix blank question
    results = Answer.joins("LEFT OUTER JOIN questions ON questions.id = answers.question_id")
                    .where(questions: { id: nil })
    report_known_invalidations(results, "Question", "missing question record")

    # Fix blank user
    results = Answer.joins("LEFT OUTER JOIN users ON users.id = answers.user_id")
                    .where(users: { id: nil })
                    .includes(plan: { roles: :user })
    report_known_invalidations(results, "Answer", "missing user record")

    # Fix duplicate question
    results = Answer.group(:question_id, :plan_id).count.select { |k,v| v > 1 }
    report_known_invalidations(results, "Answer", "question is a duplicate")

    ## ExportedPlan

    # Fix blank plan
    results = ExportedPlan
                .joins("LEFT OUTER JOIN plans on plans.id = exported_plans.plan_id")
                .where(plans: { id: nil })
    report_known_invalidations(results, "ExportedPlan", "missing plan record")

    ## GuidanceGroup

    # Fix blank org
    results = GuidanceGroup
                .joins("LEFT OUTER JOIN orgs on orgs.id = guidance_groups.org_id")
                .where(orgs: { id: nil })
    report_known_invalidations(results, "GuidanceGroup", "missing org record")

    ## Guidance

    # Fix blank guidance_group
    results = Guidance
                .joins("LEFT OUTER JOIN guidance_groups on guidance_groups.id = guidances.guidance_group_id")
                .where(guidance_groups: { id: nil })
    report_known_invalidations(results, "Guidance", "missing guidance_group record")

    ## Note

    # Fix blank user
    results = Note.joins("LEFT OUTER JOIN users on users.id = notes.user_id")
                  .where(users: { id: nil })
    report_known_invalidations(results, "Note", "missing user record")

    # Fix blank answer
    results = Note.joins("LEFT OUTER JOIN answers on answers.id = notes.answer_id")
                  .where(answers: { id: nil })
    report_known_invalidations(results, "Note", "missing answer record")

    ## Org

    # Fix blank abbreviation
    results = Org.where(abbreviation: [nil, ""])
    report_known_invalidations(results, "Org", "abbreviation is blank")

    # Fix blank feedback_email_msg
    results = Org.where(feedback_enabled: true, feedback_email_msg: [nil, ""])
    report_known_invalidations(results, "Org", "feedback_email_msg is blank")

    # Fix blank feedback_email_subject
    results = Org.where(feedback_enabled: true, feedback_email_subject: [nil, ""])
    report_known_invalidations(results, "Org", "feedback_email_subject is blank")

    # Fix blank language
    results = Org.where(language: [nil, ""])
    report_known_invalidations(results, "Org", "language is blank")

    # Fix blank contact_email
    results = Org.where.not(contact_email: [nil, ""])
                 .select { |o| o.contact_email !~ /[\w\d\.\-]+@[\w\d\.\-]/ }
    report_known_invalidations(results, "Org", "contact_email is invalid")

    ## OrgIdentifier

    # Fix blank org
    results = OrgIdentifier.joins("LEFT OUTER JOIN orgs on orgs.id = org_identifiers.org_id")
                  .where(orgs: { id: nil })
    report_known_invalidations(results, "OrgIdentifier", "missing org record")

    ## Phase

    # Fix blank template
    results = Phase.joins("LEFT OUTER JOIN templates on templates.id = phases.template_id")
                  .where(templates: { id: nil })
    report_known_invalidations(results, "Phase", "missing template record")

    # Fix duplicate number
    results = Phase.group(:number, :template_id).count.select { |k,v| v > 1 }
    report_known_invalidations(results, "Phase", "duplicate_number is invalid")

    ## Plan

    # Fix blank template
    results = Plan.joins("LEFT OUTER JOIN templates on templates.id = plans.template_id")
                  .where(templates: { id: nil })
    report_known_invalidations(results, "Plan", "missing template record")

    # Fix blank title
    results = Plan.where(title: [nil, ''])
    report_known_invalidations(results, "Plan", "title is blank")

    ## Pref

    # Fix blank user
    results = Pref.joins("LEFT OUTER JOIN users on users.id = prefs.user_id")
                  .where(users: { id: nil })
    report_known_invalidations(results, "Pref", "missing user record")

    ## Question

    # Fix blank section
    results = Question.joins("LEFT OUTER JOIN sections on sections.id = questions.section_id")
                  .where(sections: { id: nil })
    report_known_invalidations(results, "Question", "missing section record")

    # Fix blank question_format
    results = Question.joins("LEFT OUTER JOIN question_formats on question_formats.id = questions.question_format_id")
                  .where(question_formats: { id: nil })
    report_known_invalidations(results, "Question", "missing question_format record")

    # Fix duplicate number
    results = Question.group(:number, :section_id).count.select { |k,v| v > 1 }
    report_known_invalidations(results, "Question", "number is duplicate")

    ## QuestionFormat

    # Fix blank description
    results = QuestionFormat.where(description: ["", nil])
    report_known_invalidations(results, "QuestionFormat", "description is blank")

    ## QuestionOption

    # Fix blank question
    results = QuestionOption.joins("LEFT OUTER JOIN questions on questions.id = question_options.question_id")
                  .where(questions: { id: nil })
    report_known_invalidations(results, "QuestionOption", "missing question record")

    ## Region

    # Fix blank description
    results = Region.where(description: ["", nil])
    report_known_invalidations(results, "Region", "description is blank")

    ## Role

    # Fix blank plan
    results = Role.joins("LEFT OUTER JOIN plans ON plans.id = roles.plan_id")
                  .where(plans: { id: nil })
    report_known_invalidations(results, "Role", "missing plan record")

    # Fix blank user
    results = Role.joins("LEFT OUTER JOIN users ON users.id = roles.user_id")
                  .where(users: { id: nil })
    report_known_invalidations(results, "Role", "missing user record")

    ## Section

    # Fix blank phase
    results = Section.joins("LEFT OUTER JOIN phases ON phases.id = sections.phase_id")
                  .where(phases: { id: nil })
    report_known_invalidations(results, "Section", "missing phase record")

    # Fix duplicate number
    results = Section.group(:number, :phase_id).count.select { |k,v| v > 1 }
    report_known_invalidations(results, "Section", "number is duplicate")

    ## Template

    # Fix blank org
    results = Template.joins("LEFT OUTER JOIN orgs ON orgs.id = templates.org_id")
                  .where(orgs: { id: nil })
    report_known_invalidations(results, "Template", "missing org record")

    # Fix blank customization_of
    results = Template.where("customization_of is not null and customization_of not in (?)", Template.all.pluck(:family_id))
    report_known_invalidations(results, "Template", "missing customization_of record")

    # Fix blank locale
    results = Template.where(locale: [nil, ""])
    report_known_invalidations(results, "Template", "locale is blank")

    ## UserIdentifier

    # Fix blank user
    results = UserIdentifier
                .joins("LEFT OUTER JOIN users ON users.id = user_identifiers.user_id")
                .where(users: { id: nil })
    report_known_invalidations(results, "UserIdentifier", "missing user record")
  end

  private

  def report_known_invalidations(results, model_name, validation_error)
    DataCleanup.display "#{results.count} #{model_name.pluralize} with #{validation_error}", color: results.any? ? :red : :green
  end

  def rule_paths
    @rule_paths ||= Rails.root.join("lib", "data_cleanup", "rules", "*", "*.rb")
  end

  def models
    Dir[Rails.root.join("app", "models", "*.rb")].map do |model_path|
      model_path.split("/").last.gsub(".rb", "").classify.constantize
    end.sort_by(&:name)
  end
end
