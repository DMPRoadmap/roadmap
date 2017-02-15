class NewPlanTemplateStructure < ActiveRecord::Migration
  def up
    # new template tables
    create_table :templates do |t|
      t.string  :title
      t.text    :description
      t.boolean :published
      t.integer :organisation_id
      t.string  :locale
      t.boolean :is_default
      t.timestamps
      # new fields
      t.integer :version
      t.integer :visibility
      t.integer :customization_of
      t.integer :dmptemplate_id     # remove on next migration
    end

    create_table :new_phases do |t|
      t.string   :title
      t.text     :description
      t.integer  :number
      t.integer  :template_id
      t.timestamps
      t.string   :slug
      t.integer  :vid        # remove on next migration
      # new fields
      t.boolean :modifiable
    end

    create_table :new_sections do |t|
      t.string   :title
      t.text     :description
      t.integer  :number
      t.timestamps
      t.boolean  :published
      # new fields
      t.integer :new_phase_id
      t.boolean :modifiable
    end

    create_table :new_questions do |t|
      t.text     :text
      t.text     :default_value
      t.text     :guidance
      t.integer  :number
      t.integer  :new_section_id
      t.timestamps
      t.integer  :question_format_id
      t.boolean  :option_comment_display, default: true
      # new fields
      t.boolean  :modifiable
      t.integer  :question_id         # remove on next migration
    end

    create_join_table :new_questions, :themes do |t|
    end

    create_table :new_answers do |t|
      t.text     :text
      t.integer  :new_plan_id
      t.integer  :user_id
      t.integer  :new_question_id
      t.timestamps
    end

    create_table :question_options do |t|
      t.integer  :new_question_id
      t.integer  :option_id       # remove on next migration
      t.string   :text
      t.integer  :number
      t.boolean  :is_default
      t.timestamps
    end

    create_join_table :new_answers, :question_options do |t|
    end

    create_table :notes do |t|
      t.integer  :user_id
      t.text     :text
      t.boolean  :archived          # do we need this?
      t.integer  :new_answer_id
      t.integer  :archived_by       # do we need this?
      t.timestamps
    end

    create_table :new_suggested_answers do |t|
      t.integer  :new_question_id
      t.integer  :organisation_id
      t.text     :text
      t.boolean  :is_example
      t.timestamps
    end

    # new plans table
    create_table :new_plans do |t|
      t.integer  :project_id
      t.string   :title
      t.integer  :template_id
      t.timestamps
      t.string   :slug
      t.string   :grant_number
      t.string   :identifier
      t.text     :description
      t.string   :principal_investigator
      t.string   :principal_investigator_identifier
      t.string   :data_contact
      t.string   :funder_name
    end

    create_table :roles do |t|
      t.boolean :creator
      t.boolean :editor
      t.boolean :administrator
      t.integer :user_id
      t.integer :new_plan_id
      t.timestamps
    end

    # migrate all of the data from plans into templates (user facing)
    #   first migrate all "pure"(uncustomised) plans
    #     find template for plan
    #     find versions for plan
    #       find phases for template
    #         find sections for version
    #           find questions for section
    #             find question_options for question
    #             find answers for question
    #               find notes from question & link to answer
    #             find guidance_by_question for question
    #             find themes for question
    #     IF EXISTS Template SUCH THAT:
    #     dmptemplate.name = template.name,
    #       phase.title = new_phase.title,
    #         new_phase.version_id in versions.id
    #           SUCCESSFUL MATCH, copy over all data
    #   Then migrate all customised plans
    # migrate most current template into templates (org facing)
    proj_number = 0
    
    if table_exists?('projects') && table_exists?('templates') && table_exists?('answers') &&
              table_exists?('comments') && table_exists?('sections') && table_exists?('new_plan')
      # migrating uncustomised plans
      Template.transaction do
        Project.includes( { dmptemplate: [ { phases: [ { versions: [:sections] } ] } ] }, {plans: [:version ]}, :organisation).find_each(batch_size: 20) do |project|
          puts ""
          puts "beginning number #{proj_number}"
          proj_number +=1
          if project.dmptemplate.nil?               # one of the templates dosent exist
            next
          end
          new_plan = initNewPlan(project)           # copy data from project to NewPlan object
          plans = project.plans                     # select plans for project
          version_ids = []
          versions = []
          plans.each do |plan|                      # select version ids from plans list
            version_ids << plan.version.id
            versions << plan.version
          end
          dmptemplate = project.dmptemplate         # select template for project
          phases = dmptemplate.phases               # select phases for project
          temp_match = false                        # flag for if we found a matching template

          puts "checking for matching templates for #{dmptemplate.title} customised by #{project.organisation.name}" unless project.organisation.nil?
          puts "checking for matching templates for #{dmptemplate.title} uncustomised" unless project.organisation.present?
          possible_templates = project.organisation.nil? ?
            Template.includes(:new_phases).where(dmptemplate_id: dmptemplate.id, organisation_id: dmptemplate.organisation_id) :
            Template.includes(:new_phases).where(dmptemplate_id: dmptemplate.id, organisation_id: project.organisation_id)
          possible_templates.find_each do |t|  # for templates with same id
            # early cut for un-even number of phases
            new_phase_versions = t.new_phases.pluck(:vid)
            if new_phase_versions.sort == version_ids.sort
              temp_match = true                                 # flag that we found match
                                                        # we can point the new_plan to this template and init all data
              new_plan.template_id = t.id
              new_plan.save!
              puts "found a match: #{t.title} version #{t.version}"
              break
            end
          end


          # this section handles for customisations
          unless temp_match     # no matches found, init template & phase & sections & questions & themes & options
            puts "creating new template for #{dmptemplate.title}" unless project.organisation.present?
            puts "creating new template for #{dmptemplate.title} customised by #{project.organisation.name}" unless project.organisation.nil?
            modifiable = project.organisation.nil? || project.organisation_id == dmptemplate.organisation_id
            template = initTemplate(dmptemplate, modifiable, project.organisation_id)      # needs to select next version of temp based on old_temp_id
            # some differences between a customised and un-customised template
            # customised templates need a different organisation_id
            template.organisation_id = project.organisation_id unless project.organisation_id.nil?  # updated to not overwrite with nil
            # customised templates follow different version rules
            template.save!
            # since template was not a match, need to gen/copy all data below the template level
            versions.each do |version|
              new_phase = initNewPhase(version.phase, version, template, modifiable)
              new_phase.save!
              sections = []
              sections += version.sections.where("organisation_id = ? ", dmptemplate.organisation_id).pluck(:id)
              unless project.organisation_id.nil?
                sections += Section.where(organisation_id: project.organisation_id, version_id: version.id).pluck(:id)
              end
              Section.includes(questions: [:themes, :options, :suggested_answers]).where(id: sections).each do |section|
                new_section = initNewSection(section, new_phase, modifiable)
                new_section.save!
                section.questions.each do |question|
                  new_question = initNewQuestion(question, new_section, modifiable)
                  new_question.save!
                  question.themes.each do |theme|
                    new_question.themes << theme
                  end
                  question.options.each do |option|
                    question_option = initQuestionOption(option, new_question)
                    question_option.save!
                  end
                  question.suggested_answers.each do |suggested_answer|
                    new_suggested_answer = initNewSuggestedAnswers(suggested_answer, new_question)
                    new_suggested_answer.save!
                  end
                end
              end
            end
            new_plan.template_id = template.id
            new_plan.save!
          end

          # up to this point, we have either found a matching template and pointed the
          # new_plan obj at it, or we have generated a new:
          # template/phases/sections/questions/question_options/question_themes
          # now need to init answers, notes, answers_options
          #new_plan.template.new_phases.each do |new_phase|
          puts "transfering plan data"
          project.project_groups.each do |group|
            role = initRole(group, new_plan)
            role.save!
          end
          template = Template.includes(new_phases: {new_sections: :new_questions}).find(new_plan.template_id)
          template.new_phases.each do |new_phase|
            old_plan = project.plans.where(version_id: new_phase.vid).first
            puts "old plan id: #{old_plan.id}"
            puts "plan ids :#{plans.pluck(:id)}"
            if old_plan.id == 46
              puts "IT'S NOT WORKING RITE HERE!!!!!!!!!!!!!!!!!!!!!!! IT'S NOT WORKING RITE HERE!!!!!!!!!!!!!!!!!!!!!!! IT'S NOT WORKING RITE HERE!!!!!!!!!!!!!!!!!!!!!!!"
            end
            new_phase.new_sections.each do |new_section|
              new_section.new_questions.each do |new_question|
                # init new answer
                old_ans = Answer.where(question_id: new_question.question_id, plan_id: old_plan.id).order("created_at DESC").first
                # init comments on answer
                new_ans = nil
                comments = Comment.where(question_id: new_question.question_id, plan_id: old_plan.id)
                # unless there is no old answer, and no comments, create an answer
                unless old_ans.nil? && comments.length < 1
                  new_ans = initNewAnswer(old_ans, new_plan, new_question)
                  new_ans.save!
                end
                comments.find_each do |comment|
                  note = initNote(comment, new_ans)
                  note.save!
                end
                if new_ans.present? && new_ans.text.present? && new_ans.text.include?("test2")
                  puts "!!!!!!!!!!!!!!!!DEBUG MODE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                  puts "old answer: #{old_ans.text}"
                  puts "old answer: #{old_ans.id}"
                  puts "new answer: #{new_ans.text}"
                  puts "old plans: #{project.plans.pluck(:id)}"
                  puts "old_plan: #{old_plan.id}"
                  puts "old project: #{project.id}"
                  puts "question: #{new_question.question_id}"
                  puts "old user: #{old_ans.user.email}"
                end
              end
            end
          end
        end
      end

    end
    
    # indexes on join tables at the end
    change_table :new_answers_question_options do |t|
      t.index [:new_answer_id, :question_option_id], name: 'answer_question_option_index'
      t.index [:question_option_id, :new_answer_id], name: 'question_option_answer_index'
    end

    change_table :new_questions_themes do |t|
      t.index [:new_question_id, :theme_id], name: 'question_theme_index'
      t.index [:theme_id, :new_question_id], name: 'theme_question_index'
    end

  end

  def down
    drop_table :templates
    drop_table :new_phases
    drop_table :new_sections
    drop_table :new_questions
    drop_join_table :new_questions, :themes
    drop_table :new_answers
    drop_table :question_options
    drop_join_table :new_answers, :question_options
    drop_table :notes
    drop_table :new_suggested_answers
    drop_table :new_plans
    drop_table :roles
  end
end



def initTemplate(dmptemp, modifiable, organisation_id)
  if table_exists?('templates')
    template                  = Template.new
    template.title            = dmptemp.title
    template.description      = dmptemp.description
    template.published        = dmptemp.published
    template.organisation_id  = organisation_id.present? ? organisation_id : dmptemp.organisation_id
    template.locale           = dmptemp.locale
    template.is_default       = dmptemp.is_default
    template.created_at       = dmptemp.created_at
    template.updated_at       = dmptemp.updated_at
    template.visibility       = 0                   # dummy value for private
    template.customization_of = modifiable ? nil : dmptemp.id
    template.dmptemplate_id   = dmptemp.id
    # if no templates with the same dmptemplate_id and organisation_id exist
    #   0
    # otherwise
    #   take the maximum version from templates with the same dmptemplate_id and organisation_id and add 1
    template.version          = Template.where(dmptemplate_id: dmptemp.id, organisation_id: template.organisation_id).blank? ?
      0 : Template.where(dmptemplate_id: dmptemp.id, organisation_id: template.organisation_id).pluck(:version).max + 1
    puts "NEW TEMPLATE: \n  title: #{template.title} \n  version: #{template.version} \n  others_present? #{Template.where(dmptemplate_id: dmptemp.id).count}"
    return template
    
  else
    return nil
  end
end

def initNewPhase(phase, version, temp, modifiable)
  new_phase                 = NewPhase.new
  new_phase.title           = phase.title
  new_phase.description     = phase.description
  new_phase.number          = phase.number
  new_phase.template_id     = temp.id
  new_phase.created_at      = phase.created_at
  new_phase.updated_at      = phase.updated_at
  new_phase.slug            = phase.slug
  new_phase.vid             = version.id
  new_phase.modifiable      = modifiable
  return new_phase
end

def initNewSection(section, new_phase, modifiable)
  new_section               = NewSection.new
  new_section.title         = section.title
  new_section.description   = section.description
  new_section.number        = section.number
  new_section.published     = section.published
  new_section.new_phase_id  = new_phase.id
  new_section.modifiable    = modifiable
  new_section.created_at    = section.created_at
  new_section.updated_at    = section.updated_at
  return new_section
end

def initNewQuestion(question, new_section, modifiable)
  new_question                        = NewQuestion.new
  new_question.text                   = question.text
  new_question.default_value          = question.default_value
  new_question.guidance               = question.guidance.nil? ? "" : question.guidance
  if table_exists?('guidances')
    Guidance.where(question_id: question.id).each do |guidance|
      new_question.guidance             += guidance.text
    end
  end
  new_question.number                 = question.number
  new_question.new_section_id         = new_section.id
  new_question.question_format_id     = question.question_format_id
  new_question.option_comment_display = question.option_comment_display
  new_question.modifiable             = modifiable
  new_question.question_id            = question.id
  new_question.updated_at             = question.updated_at
  new_question.created_at             = question.created_at
  return new_question
end

def initNewAnswer(answer, new_plan, new_question)
  new_answer                  = NewAnswer.new
  unless answer.nil?
    new_answer.text             = answer.text
    new_answer.new_plan_id      = new_plan.id
    new_answer.new_question_id  = new_question.id
    new_answer.user_id          = answer.user_id
    new_answer.created_at       = answer.created_at
    new_answer.updated_at       = answer.updated_at
    # not sure if these get saved properly as new_answer has no id yet
    if table_exists?('question_options')
      answer.options.each do |option|
        new_answer.question_options << QuestionOption.find_by(option_id: option.id)
      end
    end
  end
  return new_answer
end

def initQuestionOption(option, new_question)
  if table_exists?('question_options')
    question_option                 = QuestionOption.new
    question_option.new_question_id = new_question.id
    question_option.option_id       = option.id
    question_option.text            = option.text
    question_option.number          = option.number
    question_option.is_default      = option.is_default
    question_option.created_at      = option.created_at
    question_option.updated_at      = option.updated_at
    return question_option
  else
    return nil
  end
end

def initNote(comment, new_answer)
  if table_exists?('notes')
    note                  = Note.new
    note.user_id          = comment.user_id
    note.text             = comment.text
    note.archived         = comment.archived
    note.archived_by      = comment.archived_by
    note.new_answer_id    = new_answer.id
    note.created_at       = comment.created_at
    note.updated_at       = comment.updated_at
    return note
  else
    return nil
  end
end

def initNewPlan(project)
  new_plan              = NewPlan.new
  new_plan.project_id   = project.id
  new_plan.title        = project.title
  new_plan.slug         = project.slug
  new_plan.grant_number = project.grant_number
  new_plan.identifier   = project.identifier
  new_plan.description  = project.description
  new_plan.principal_investigator             = project.principal_investigator
  new_plan.principal_investigator_identifier  = project.principal_investigator_identifier
  new_plan.data_contact = project.data_contact
  new_plan.funder_name  = project.funder_name
  new_plan.created_at   = project.created_at
  new_plan.updated_at   = project.updated_at
  return new_plan
end

def initNewSuggestedAnswers(suggested_answer, new_question)
  new_suggested_answer                  = NewSuggestedAnswer.new
  new_suggested_answer.text             = suggested_answer.text
  new_suggested_answer.organisation_id  = suggested_answer.organisation_id
  new_suggested_answer.new_question_id  = new_question.id
  new_suggested_answer.is_example       = suggested_answer.is_example
  new_suggested_answer.created_at       = suggested_answer.created_at
  new_suggested_answer.updated_at       = suggested_answer.updated_at
  return new_suggested_answer
end

def initRole(project_group, new_plan)
  if table_exists?('roles')
    role                = Role.new
    role.creator        = project_group.project_creator
    role.administrator  = project_group.project_administrator
    role.editor         = project_group.project_editor
    role.created_at     = project_group.created_at
    role.updated_at     = project_group.updated_at
    role.user_id        = project_group.user_id
    role.new_plan_id    = new_plan.id
    return role
  else
    return nil
  end
end
