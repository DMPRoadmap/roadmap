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