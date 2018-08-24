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

    # Find with blank text
    results = Annotation.where(text: [nil, ""])
    report_known_invalidations(results, "Annotation", "text is blank")

    # Find with duplicate type
    results = Annotation.group(:question_id, :type, :org_id)
                .count
                .select { |k,v| v > 1 }
    report_known_invalidations(results, "Annotation", "type is a duplicate")

    ## Answer

    # Fix blank user
    results = Answer.joins("LEFT OUTER JOIN users ON users.id = answers.user_id")
                    .where(users: { id: nil })
                    .includes(plan: { roles: :user })
    report_known_invalidations(results, "Answer", "user is blank")

    # Fix duplicate question
    results = Answer.group(:question_id, :plan_id).count.select { |k,v| v > 1 }
    report_known_invalidations(results, "Answer", "question is a duplicate")

    ## ExportedPlan

    # Fix blank plan
    results = ExportedPlan
                .joins("LEFT OUTER JOIN plans on plans.id = exported_plans.plan_id")
                .where(plans: { id: nil })
    report_known_invalidations(results, "ExportedPlan", "plan is blank")

    ## Org

    # Fix blank abbreviation
    results = Org.where(abbreviation: [nil, ""])
    report_known_invalidations(results, "Org", "abbreviation is blank")

    # Fix blank feedback_email_msg
    results = Org.where(feedback_enabled: true, feedback_email_msg: [nil, ""])
    report_known_invalidations(results, "Org", "feedback_email_msg is blank")

    results = Org.where(feedback_enabled: true, feedback_email_subject: [nil, ""])
    report_known_invalidations(results, "Org", "feedback_email_subject is blank")

    results = Org.where(language: [nil, ""])
    report_known_invalidations(results, "Org", "language is blank")

    results = Org.where.not(contact_email: [nil, ""])
                 .select { |o| o.contact_email !~ /[\w\d\.\-]+@[\w\d\.\-]/ }
    report_known_invalidations(results, "Org", "contact_email is invalid")

    ## Phase

    # Fix duplicate number
    results = Phase.group(:number, :template_id).count.select { |k,v| v > 1 }
    report_known_invalidations(results, "Phase", "duplicate_number is invalid")

    ## Plan

    # Fix blank title
    results = Plan.where(title: [nil, ''])
    report_known_invalidations(results, "Plan", "title is blank")

    ## Question

    # Fix duplicate number
    results = Question.group(:number, :section_id).count.select { |k,v| v > 1 }
    report_known_invalidations(results, "Question", "number is duplicate")

    ## QuestionFormat

    # Fix blank description
    results = QuestionFormat.where(description: ["", nil])
    report_known_invalidations(results, "QuestionFormat", "description is blank")

    ## Region

    # Fix blank description
    results = Region.where(description: ["", nil])
    report_known_invalidations(results, "Region", "description is blank")

    ## Role

    # Fix blank plan
    results = Role.joins("LEFT OUTER JOIN plans ON plans.id = roles.plan_id")
                  .where(plans: { id: nil })
    report_known_invalidations(results, "Role", "plan is blank")

    ## Section

    # Fix duplicate number
    results = Section.group(:number, :phase_id).count.select { |k,v| v > 1 }
    report_known_invalidations(results, "Section", "number is duplicate")

    ## Template

    # Fix blank locale
    results = Template.where(locale: [nil, ""])
    report_known_invalidations(results, "Template", "locale is blank")

    ## UserIdentifier

    # Fix blank user
    results = UserIdentifier
                .joins("LEFT OUTER JOIN users ON users.id = user_identifiers.user_id")
                .where(users: { id: nil })
    report_known_invalidations(results, "UserIdentifier", "user is blank")
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
