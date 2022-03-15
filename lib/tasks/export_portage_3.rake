
require 'faker'
namespace :export do
    desc "Export guidances from 3.0.2 database" 
    task :export_portage_3 => :environment do
        GuidanceGroup.all.each do |guidance_group|
            guidances = Guidance.where(:guidance_group_id => guidance_group.id) 
            guidances.all.each do |guidance|
                guidance.theme_ids = [Theme.all.sample.id]
                excluded_keys = ['created_at','updated_at'] 
                serialized = guidance.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                puts "Guidance.create(#{serialized})"
            end
        end
    end
    desc "Export templates and corresponding components from 3.0.2 database" 
    task :export_portage_3 => :environment do
        Template.all.each do |template|
            # since too many version of template could cause rake to crash on seeding process, just get the published version
            excluded_keys = ['created_at','updated_at']
            serialized = template.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
            puts "Template.create(#{serialized})"
            # create phases
            phases = Phase.where(:template_id => template.id) # retrieve template old id
            phases.all.each do |phase|
                excluded_keys = ['created_at','updated_at'] 
                serialized = phase.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                puts "Phase.create(#{serialized})"
                # create sections
                sections = Section.where(:phase_id => phase.id)
                sections.all.each do |section|
                    excluded_keys = ['created_at','updated_at'] 
                    serialized = section.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                    puts "Section.create(#{serialized})"
                    # create questions
                    questions = Question.where(:section_id => section.id)
                    questions.all.each do |question|
                        excluded_keys = ['created_at','updated_at'] 
                        serialized = question.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                        puts "Question.create(#{serialized})"
                        # create question options
                        question_options = QuestionOption.where(:question_id => question.id)
                        question_options.all.each do |question_option|
                        excluded_keys = ['created_at','updated_at'] 
                        serialized = question_option.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
                        puts "QuestionOption.create(#{serialized})"
                        end
                    end
                end
            end
        end 
    end
    desc "Export annotations from 3.0.2 database" 
    task :export_portage_3 => :environment do
        Annotation.all.each do |annotation|
            excluded_keys = ['created_at','updated_at'] 
            serialized = annotation.serializable_hash.delete_if{|key,value| excluded_keys.include?(key)} 
            puts "Annotation.create(#{serialized})"
        end
    end
end