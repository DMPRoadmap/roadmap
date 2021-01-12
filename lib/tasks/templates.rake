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
  task :export_template_by_id, [:template_id] => [:environment] do |task, args|
    # Template 3118 is our current Portage templatee
    template = Template.find args[:template_id]

    # has_many :plans
    # has_many :phases, dependent: :destroy
    # has_many :sections, through: :phases
    # has_many :questions, through: :sections
    # has_many :annotations, through: :questions

    # Phases
    # Sections
    # Questions
    # Annotations
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
      # puts "Phase id #{phase.id}"
      output[:phases] << phase
      phase.sections.each do |section|
        # puts "Section id #{section.id}"
        # Create section
        output[:sections] << section
        section.questions.each do |question|
          # puts "Question id #{question.id}"
          # Create question
          output[:questions] << question
          question.annotations.each do |annotation|
            # puts "Annotation id #{annotation.id}"
            # Create annotation
            output[:annotations] << annotation
          end
        end
      end
    end

    puts output.to_json

  end

  desc "Import new template"
  task import_new_template: :environment do
    file = File.read('/home/orodrigu/Workspace/roadmap/portage_template.json')
    data = JSON.parse(file)

    templates_ids = {}
    phases_ids = {}
    sections_ids = {}
    questions_ids = {}
    annotations_ids = {}

    data["templates"].each do |template_json|
      template = Template.new(template_json.except[:id])
      template.name = "Portage testing"
      # SAVE
      template.save!
      templates_ids[template_json[:id]] = template
    end

    data["phases"].each do |phase_json|
      phase = Phase.new(phase_json.except([:id, :template_id]))
      phase.template = templates_ids[phase_json[:template_id]]
      # SAVE
      phase.save!
      phases_ids[phase_json[:id]] = phase
    end

    data["sections"].each do |section_json|
      section = Section.new(section_json.except([:id, :phase_id]))
      section.phase = phases_ids[section_json[:phase_id]]
      # SAVE
      section.save!
      sections_ids[section_json[:id]] = section
    end

    data["questions"].each do |question_json|
      question = Question.new(question_json.except([:id, :section_id]))
      question.section = sections_ids[question_json[:section_id]]
      # SAVE
      question.save!
      questions_ids[question_json[:id]] = question
    end

    data["annotations"].each do |annotation_json|
      annotation = Annotation.new(annotation_json.except([:id, :question_id]))
      annotation.question = questions_ids[annotation_json[:question_id]]
      annotation.save!
      # SAVE
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