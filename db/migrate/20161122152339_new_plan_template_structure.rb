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
      t.integer :dmptemplate_id
      t.boolean :migrated
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

    create_table :annotations do |t|
      t.integer  :new_question_id
      t.integer  :organisation_id
      t.text     :text
      t.column :type, :integer, default: 0, null: false
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

    # new plans relation to guidance groups
    create_table :new_plans_guidance_groups do |t|
      t.integer :guidance_group_id
      t.integer :new_plan_id
    end

    create_table :roles do |t|
      t.boolean :creator
      t.boolean :editor
      t.boolean :administrator
      t.integer :user_id
      t.integer :new_plan_id
      t.timestamps
    end

    change_table :projects do |t|
      t.index :dmptemplate_id
    end
    change_table :projects do |t|
      t.index :organisation_id
    end
    change_table :sections do |t|
      t.index :version_id
    end
    change_table :plans do |t|
      t.index :version_id
    end
    change_table :plans do |t|
      t.index :project_id
    end
    change_table :answers do |t|
      t.index :question_id
      t.index :plan_id
    end
    change_table :questions do |t|
      t.index :section_id
    end
    change_table :options do |t|
      t.index :question_id
    end
    change_table :suggested_answers do |t|
      t.index :question_id
    end
    change_table :suggested_answers do |t|
      t.index :organisation_id
    end
    change_table :comments do |t|
      t.index :question_id
      t.index :plan_id
    end


    change_table :templates do |t|
      t.index [:organisation_id, :dmptemplate_id], name: 'template_organisation_dmptemplate_index'
    end
    change_table :templates do |t|
      t.index :organisation_id
    end
    change_table :new_phases do |t|
      t.index :template_id
    end
    change_table :new_plans do |t|
      t.index :template_id
    end
    change_table :new_phases do |t|
      t.index :vid
    end
    change_table :new_sections do |t|
      t.index :new_phase_id
    end
    change_table :new_questions do |t|
      t.index :new_section_id
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
    # migrating uncustomised plans
    Template.transaction do
      Project.includes( { dmptemplate: [ { phases: [ { versions: [:sections] } ] } ] }, {plans: [:version ]}, :organisation).find_each(batch_size: 100) do |project|
        #puts ""
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
          version_ids << plan.version.id unless plan.version.nil?
          versions << plan.version unless plan.version.nil?
        end
        dmptemplate = project.dmptemplate         # select template for project
        phases = dmptemplate.phases               # select phases for project
        temp_match = false                        # flag for if we found a matching template

        #puts "checking for matching templates for #{dmptemplate.title} customised by #{project.organisation.name}" unless project.organisation.nil?
        #puts "checking for matching templates for #{dmptemplate.title} uncustomised" unless project.organisation.present?
        possible_templates = project.organisation.nil? ?
          Template.includes(:new_phases).where(dmptemplate_id: dmptemplate.id, organisation_id: dmptemplate.organisation_id) :
          Template.includes(:new_phases).where(customization_of: dmptemplate.id, organisation_id: project.organisation_id)
        possible_templates.find_each do |t|  # for templates with same id
          # early cut for un-even number of phases
          new_phase_versions = t.new_phases.pluck(:vid)
          if new_phase_versions.sort == version_ids.sort
            temp_match = true                                 # flag that we found match
                                                      # we can point the new_plan to this template and init all data
            new_plan.template_id = t.id
            new_plan.save!
            #puts "found a match: #{t.title} version #{t.version}"
            break
          end
        end


        # this section handles for customisations
        unless temp_match     # no matches found, init template & phase & sections & questions & themes & options
          #puts "creating new template for #{dmptemplate.title}" unless project.organisation.present?
          #puts "creating new template for #{dmptemplate.title} customised by #{project.organisation.name}" unless project.organisation.nil?
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
              if project.organisation_id.nil?
                sec_mod = modifiable
              else
                sec_mod = (section.organisation_id == project.organisation_id)
              end
              new_section = initNewSection(section, new_phase, sec_mod)
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
                  # only bring suggested answers from the template creator or the
                  # project's org(customizations)
                  if suggested_answer.organisation_id == template.organisation_id ||
                    suggested_answer.organisation_id == project.dmptemplate.organisation_id
                    if suggested_answer.text.present?
                      annotation = initAnnotationSA(suggested_answer, new_question)
                      annotation.save!
                    end
                  end
                end
                # question.guidance field to annotation if present
                if question.guidance.present?
                  if new_question.modifiable
                    org_id = template.organisation_id
                  else
                    org_id = project.dmptemplate.organisation_id
                  end
                  annotation = initAnnotationQuestion(question, new_question, org_id)
                  annotation.save!
                end
                Guidance.where(question_id: question.id).each do |guidance|
                  if guidance.guidance_groups.present?
                    annotation = initAnnotationGuidance(guidance, new_question)
                    annotation.save!
                  end
                  # ported over the data, remove the old guidance record
                  # also removes the orphaned guidances
                  guidance.destroy!
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
        #puts "transfering plan data"
        project.project_groups.each do |group|
          role = initRole(group, new_plan)
          role.save!
        end
        template = Template.includes(new_phases: {new_sections: :new_questions}).find(new_plan.template_id)
        template.new_phases.each do |new_phase|
          old_plan = project.plans.where(version_id: new_phase.vid).first
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
            end
          end
        end
      end

      # transfer over the current published version and working copy of each
      # dmptemplate.  Additionally take only those customizations for which there
      # are sections
      temps = 0
      Dmptemplate.includes(phases: :versions).all.each do |dtemp|
      #.includes(phases: {versions:{sections:{questions: [:themes, :options, :suggested_answers]}}})
        puts "migrating template #{temps}: #{dtemp.title}"
        temps = temps + 1
        phases = dtemp.phases
        # determine the most up to date version for each phase (published if exists)
        version_ids = []
        phases.each do |phase|
          # should this be true,false or false,true
          vers = get_version(phase, true, false)
          version_ids << vers.id unless vers.nil?
        end
        # figure out which organisations have customised the template (or wrote it)
        org_ids = Section.where(version_id: version_ids).pluck(:organisation_id)
        # turns out that that alone dosent capture all customised templates
        Version.where(id:version_ids).each do |vers|
          vers.sections.each do |sec|
            sec.questions.each do |q|
              q.suggested_answers.each do |sa|
                org_ids << sa.organisation_id
              end
            end
          end
        end
        org_ids << dtemp.organisation_id
        org_ids.uniq!
        puts "#{org_ids}"
        # need to come up with a unique dmptemplate_id for the non-legacy template
        # to use.  otherwise version numbers will be confusing
        dmptemplate_id = generate_dmptemplate_id()
        # flag to check if we have already copied over the published
        published_copied = false
        # iterate over these orgs to generate the correct customised and
        # un-customised templates
        org_ids.each do |org_id|
          # is this a customisation?
          modifiable = org_id == dtemp.organisation_id
          puts modifiable ? "  -Template by #{org_id}" : "  -Customised by #{org_id}"
          customization_of = modifiable ? nil : dmptemplate_id
          new_temp = initTemplate(dtemp, modifiable, org_id, false, dmptemplate_id, customization_of)
          # newest version of template is always unpublished
          if modifiable && published_copied
            new_temp.published = false
          end
          new_temp.save!
          # for each phase in the template
          phases.each do |phase|
            # for customised templates, we want published versions
            # for non-customised templates we want two things:
            #   - published version
            #   - most recent version of everything
            if !modifiable
              version = get_version(phase,true,false)
            elsif !published_copied
              version = get_version(phase,true, false)
            else published_copied
              version = get_version(phase,false,false)
            end
            if version.present?
              new_phase = initNewPhase(phase, version, new_temp, modifiable)
              new_phase.save
              # ISSUE: This just copies over all the sections
              Section.includes(questions: [:themes, :options, :suggested_answers]).where(version_id: version.id, organisation_id: [org_id, dtemp.organisation_id]).each do |section|
                sec_mod = section.organisation_id == org_id
                new_section = initNewSection(section, new_phase, sec_mod)
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
                    # only bring suggested answers from the template creator or the
                    # project's org(customizations)
                    if suggested_answer.organisation_id == dtemp.organisation_id ||
                      suggested_answer.organisation_id == org_id
                      if suggested_answer.text.present?
                        annotation = initAnnotationSA(suggested_answer, new_question)
                        annotation.save!
                      end
                    end
                  end
                  # question.guidance field to annotation if present
                  if question.guidance.present?
                    if new_question.modifiable
                      q_org_id = org_id
                    else
                      q_org_id = dtemp.organisation_id
                    end
                    annotation = initAnnotationQuestion(question, new_question, q_org_id)
                    annotation.save!
                  end
                  Guidance.where(question_id: question.id).each do |guidance|
                    if guidance.guidance_groups.present?
                      annotation = initAnnotationGuidance(guidance, new_question)
                      annotation.save!
                    end
                  end
                end
              end
            end
          end
          # repeat the loop for the creating organisation to copy over the most
          # current version of their template which may not be published
          if modifiable && !published_copied
            published_copied = true
            redo
          end
        end
      end

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
    drop_table :annotations
    drop_table :new_plans
    drop_table :roles
    drop_table :new_plans_guidance_groups
  end
end

def generate_dmptemplate_id()
  return loop do
    random = rand 2147483647  # max int field in psql
    break random unless Template.exists?(dmptemplate_id: random) || Dmptemplate.exists?(id: random)
  end
end

def get_version(phase, published, all)
  # can return nill ONLY with published=true
  version = nil
  if published
    pub_vers = phase.versions.where(published: true).order(updated_at: 'desc')
    if pub_vers.any?
      version = pub_vers.first
    end
  elsif all
    pub_vers = phase.versions.where(published: true).order(updated_at: 'desc')
    if pub_vers.any?
      version = pub_vers.first
    else
      version = phase.versions.order(created_at: 'desc').first
    end
  else
    version = phase.versions.order(created_at: 'desc').first
  end
  return version
end

def initTemplate(dmptemp, modifiable, organisation_id, legacy=true, dmptemplate_id=nil, customization_of=nil)
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
  if customization_of.nil?
    template.customization_of = modifiable ? nil : dmptemp.id
  else
    template.customization_of = modifiable ? nil : customization_of
  end
  template.migrated         = legacy
  # needs to be dmptemp.id if not a customization
  # if it is a customization,
  if modifiable
    template.dmptemplate_id = dmptemplate_id.nil? ? dmptemp.id : dmptemplate_id
  else
    customization_temp = Template.where(customization_of: dmptemp.id, organisation_id: template.organisation_id).first
    if customization_temp.present?
      template.dmptemplate_id = customization_temp.dmptemplate_id
    else
      template.dmptemplate_id = generate_dmptemplate_id()
    end
  end
  # if no templates with the same dmptemplate_id and organisation_id exist
  #   0
  # otherwise
  #   take the maximum version from templates with the same dmptemplate_id and organisation_id and add 1
  template.version          = Template.where(dmptemplate_id: template.dmptemplate_id, organisation_id: template.organisation_id).blank? ?
    0 : Template.where(dmptemplate_id: template.dmptemplate_id, organisation_id: template.organisation_id).pluck(:version).max + 1
  #puts "NEW TEMPLATE: \n  title: #{template.title} \n  version: #{template.version} \n  others_present? #{Template.where(dmptemplate_id: dmptemp.id).count}"
  return template
end

def initNewPhase(phase, version, temp, modifiable)
  new_phase                 = NewPhase.new
  new_phase.title           = phase.title
  new_phase.description     = phase.description
  new_phase.number          = phase.number
  new_phase.template_id     = temp.id
  new_phase.created_at      = version.created_at
  new_phase.updated_at      = version.updated_at
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
    answer.options.each do |option|
      new_answer.question_options << QuestionOption.find_by(option_id: option.id)
    end
  end
  return new_answer
end

def initQuestionOption(option, new_question)
  question_option                 = QuestionOption.new
  question_option.new_question_id = new_question.id
  question_option.option_id       = option.id
  question_option.text            = option.text
  question_option.number          = option.number
  question_option.is_default      = option.is_default
  question_option.created_at      = option.created_at
  question_option.updated_at      = option.updated_at
  return question_option
end

def initNote(comment, new_answer)
  note                  = Note.new
  note.user_id          = comment.user_id
  note.text             = comment.text
  note.archived         = comment.archived
  note.archived_by      = comment.archived_by
  note.new_answer_id    = new_answer.id
  note.created_at       = comment.created_at
  note.updated_at       = comment.updated_at
  return note
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
  new_plan.save!
  #init guidance groups
  project.guidance_groups.each do |group|
    new_plan.guidance_groups << group
  end
  return new_plan
end

def initAnnotationSA(suggested_answer, new_question)
  annotation                  = Annotation.new
  annotation.text             = suggested_answer.text
  annotation.organisation_id  = suggested_answer.organisation_id
  annotation.new_question_id  = new_question.id
  annotation.created_at       = suggested_answer.created_at
  annotation.updated_at       = suggested_answer.updated_at
  annotation.example_answer!
  return annotation
end

def initAnnotationGuidance(guidance, new_question)
  annotation = Annotation.new
  annotation.text = guidance.text
  annotation.organisation_id = guidance.guidance_groups.first.organisation_id
  annotation.new_question_id = new_question.id
  annotation.created_at = guidance.created_at
  annotation.updated_at = guidance.updated_at
  annotation.guidance!
  return annotation
end

def initAnnotationQuestion(question, new_question, organisation_id)
  annotation = Annotation.new
  annotation.text = question.guidance
  annotation.organisation_id = organisation_id
  annotation.new_question_id = new_question.id
  annotation.created_at = question.created_at
  annotation.updated_at = question.updated_at
  annotation.guidance!
  return annotation
end

def initRole(project_group, new_plan)
  role                = Role.new
  role.creator        = project_group.project_creator
  role.administrator  = project_group.project_administrator
  role.editor         = project_group.project_editor
  role.created_at     = project_group.created_at
  role.updated_at     = project_group.updated_at
  role.user_id        = project_group.user_id
  role.new_plan_id    = new_plan.id
  return role
end
