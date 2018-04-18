module Versionable
  extend ActiveSupport::Concern

  def get_modifiable(obj)
    if obj.respond_to? 'template'
      template = obj.template
    elsif obj.is_a? Template
      template = obj
    else
      return nil # Throw error as wrong obj added
    end
    template, copy = find_or_generate(template)
    # copy not generated - return obj
    # copy generated and obj.is_a? template - return template
    if copy
      if obj.is_a? Template
        obj = template
      else
        obj = find_in_space(obj,template.phases)
      end
    end
    return obj
  end

  ##
  # Creates a new verison IF template published
  # to be called from the create/update/destroy actions of
  #    phases/sections/questions/annotations
  # @param template  -  Template object
  # @return Template (new or current version)
  def find_or_generate(template)
    if template.generate_version?
      new_template = template.generate_version!
      return new_template, true
    end
    return template, false
  end


  ##
  # Find the corresponding object
  def find_in_space(obj, search_space)
    # obj can be a phase/section/question/annotation
    # case of objet being an instance of search space
    puts search_space.first.class
    puts search_space
    if obj.is_a? search_space.first.class
      puts "match"
      if obj.respond_to?('number') && search_space.first.respond_to?('number')
        return search_space.find{|search| search.number == obj.number}
      else # object must be an annotation
        return search_space.find{|search| (search.text = obj.text) and (search.org_id == obj.org_id)}
      end
    end
    # case of object not being an instance of search space
    case search_space.first
    when Phase
      comp = obj.phase.number
      nxt = 'sections'
      puts 'phase'
    when Section
      comp = obj.section.number
      nxt = 'questions'
      puts 'section'
    when Question
      puts 'question'
      comp = obj.question.number
      nxt = 'annotations'
    when Annotation
      puts 'something broke'
    end
    return find_in_space(obj, search_space.find{|search| search.number == comp}.public_send(nxt))
  end

end
