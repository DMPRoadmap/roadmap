module Versionable
  extend ActiveSupport::Concern

  ##
  # Takes in a Template, phase, Section, Question, or Annotaion
  # IF the template is published, generates a new template
  # finds the passed object in the new template
  # @param obj - Template, Phase, Section, Question, Annotation
  # @return type_of(obj)
  def get_modifiable(obj)
    if obj.respond_to? 'template'
      template = obj.template
    elsif obj.is_a? Template
      template = obj
    else
      raise ArgumentError, _('obj should be a Template, Phase, Section, Question, or Annotation') # Throw error as wrong obj added
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
  # Takes in a phase, Section, Question, or Annotation which is newly
  # generated and returns a modifiable verson of that object
  # NOTE: the passed obj is still not saved, but it's parent_id will be updated
  def get_new(obj)
    if obj.respond_to? 'template'
      template = obj.template
    else
      raise ArgumentError, _('obj should be a Phase, Section, Question, or Annotation') # Throw error as wrong obj added
    end
    template, copy = find_or_generate(template)
    if copy
      case obj
      when Phase
        par = 'template'
      when Section
        par = 'phase'
      when Question
        par = 'section'
      when Annotation
        par = 'question'
      end

      if par=='template'
        obj.template_id = template.id
      elsif par.present?
        parent = find_in_space(obj.public_send(par),template.phases)
        par += "_id="
        obj.public_send(par,parent.id)
      else
        raise ArgumentError,  _('obj should be a Phase, Section, Question, or Annotation')
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
    if obj.is_a? search_space.first.class
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
    when Section
      comp = obj.section.number
      nxt = 'questions'
    when Question
      nxt = 'annotations'
      comp = obj.question.number
    end
    return find_in_space(obj, search_space.find{|search| search.number == comp}.public_send(nxt))
  end

end
