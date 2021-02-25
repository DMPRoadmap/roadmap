namespace :templates do
  
  desc "Initializes the dirty flag on templates"
  task set_dirty_flags: :environment do
    Org.all.each do |org|
      Template.dmptemplate_ids(org).each do |id|
        current = Template.current(org, id)
        live = Template.live(org, id)
        
        # If its been published or the current date is greater than the live date then it has outstanding changes
        if !live.nil? 
          if live.updated_at.strftime("%Y-%m-%d %H:%M") < 
             current.updated_at.strftime("%Y-%m-%d %H:%M")
             
            current.dirty = true
            current.save!
          end
        end
      end
    end
  end
  
  desc "Cleanup published flags"
  task clean_up_published_flags: :environment do
    Org.all.each do |org|
      Template.dmptemplate_ids(org).each do |id|
        live = Template.live(org, id)
        
        # If its been published or the current date is greater than the live date then it has outstanding changes
        if !live.nil? 
          Template.where("updated_at < ? AND published = ?", 
                              live.updated_at, true).each do |template|
            template.published = false
            template.save!
          end
        end
      end
    end
  end

  desc "Export template by Id"
  # This task requires to pass the template id from the command line as
  # rake templates:export_template_by_id[3120] > exported_template.json
  task :export_template_by_id, [:template_id] => [:environment] do |task, args|
    # Template 3118 is our current Portage templatee
    template = Template.find args[:template_id]

    # has_many :plans
    # has_many :phases, dependent: :destroy
    # has_many :sections, through: :phases
    # has_many :questions, through: :sections
    # has_many :annotations, through: :questions

    output = {
      templates: [],
      phases: [],
      sections: [],
      questions: [],
      annotations: []
    }

    output[:templates] << template

    template.phases.each do |phase|
      # Create phase
      output[:phases] << phase
      phase.sections.each do |section|
        # Create section
        output[:sections] << section
        section.questions.each do |question|
          # Create question
          output[:questions] << question
          question.annotations.each do |annotation|
            # Create annotation
            output[:annotations] << annotation
          end
        end
      end
    end

    puts output.to_json

  end

  desc "Import new template"
  # This task requires to pass the template id from the command line as
  # rake templates:import_new_template['./exported_template.json']
  task :import_new_template, [:file_path] => [:environment] do |task, args|
    file_path =  args[:file_path]
    file = File.read(file_path)
    data = JSON.parse(file, symbolize_names: true)

    templates_ids = {}
    phases_ids = {}
    sections_ids = {}
    questions_ids = {}
    annotations_ids = {}

    data[:templates].each do |template_json|      
      template = Template.new(template_json.except(:id))
      old_saved_templates = Template.where(family_id: template_json[:family_id], version: template_json[:version])

      if old_saved_templates.length > 0
        t = Template.where(family_id: template_json[:family_id])
                    .order(:version).last
        template[:version] = t[:version] + 1
      end
      
      template.save!
      templates_ids[template_json[:id]] = template
    end

    data[:phases].each do |phase_json|
      phase = Phase.new(phase_json.except(:id, :template_id))
      phase.template = templates_ids[phase_json[:template_id]]
      phase.save!
      phases_ids[phase_json[:id]] = phase
    end

    data[:sections].each do |section_json|
      section = Section.new(section_json.except(:id, :phase_id))
      section.phase = phases_ids[section_json[:phase_id]]
      section.save!
      sections_ids[section_json[:id]] = section
    end

    data[:questions].each do |question_json|
      question = Question.new(question_json.except(:id, :section_id))
      question.section = sections_ids[question_json[:section_id]]
      question.save!
      questions_ids[question_json[:id]] = question
    end

    data[:annotations].each do |annotation_json|
      annotation = Annotation.new(annotation_json.except(:id, :question_id))
      annotation.question = questions_ids[annotation_json[:question_id]]
      annotation.save!
    end

  end

  
  desc "Cleanup excess versions"
  task clean_up_excess_versions: :environment do
    Org.all.each do |org|
      Template.dmptemplate_ids(org).each do |id|
        versions = Template.where(org: org, dmptemplate_id: id).pluck(:version).uniq
        
        # Only keep the latest record for each version
        versions.each do |ver|
          templates = Template.where(org: org, dmptemplate_id: id, version: ver).order(published: :desc, updated_at: :desc)
          
          # If there is more than one record with the same version then delete it
          if templates.count > 1
            templates[1..templates.count].each do |t|
              if t.plans.count <= 0
              
                # Cycle through all of this template's dependencies first
                t.phases.each do |p|
                  p.sections.each do |s|
                    s.questions.each do |q|
                      q.suggested_answers do |sa|
                        sa.destroy
                      end
                    
                      q.question_options do |qo|
                        qo.destroy
                      end
                    
                      q.destroy
                    end
                  
                    s.destroy
                  end
                
                  p.destroy
                end
              
                t.destroy
                
              else
                puts "UNABLE to delete #{t.id} because it has a plan"
              end  
            end
          end
        end
      end
    end
  end
end