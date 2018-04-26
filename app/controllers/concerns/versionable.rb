module Versionable
  extend ActiveSupport::Concern

  included do
    ##
    # Takes in a Template, phase, Section, Question, or Annotaion
    # IF the template is published, generates a new template
    # finds the passed object in the new template
    # @param obj - Template, Phase, Section, Question, Annotation
    # @return type_of(obj)
    def get_modifiable(obj)
      if obj.respond_to?(:template)
        template = obj.template
      elsif obj.is_a?(Template)
        template = obj
      else
        raise ArgumentError, _('obj should be a Template, Phase, Section, Question, or Annotation')
      end
      
      new_template = Template.find_or_generate_version!(template) # raises RuntimeError if template is not latest

      if new_template != template
        if obj.is_a?(Template)
          obj = new_template
        else
          obj = find_in_space(obj,new_template.phases)
        end
      end
      return obj
    end
    ##
    # Takes in a phase, Section, Question, or Annotation which is newly
    # generated and returns a modifiable version of that object
    # NOTE: the obj passed is still not saved however it should belongs to a parent already
    def get_new(obj)
      raise ArgumentError, _('obj should be a Phase, Section, Question, or Annotation') unless obj.respond_to?(:template)

      template = obj.template
      new_template = Template.find_or_generate_version!(template) # raises RuntimeError if template is not latest

      if new_template != template # Copied version
        case obj
          when Phase
            belongs = :template
          when Section
            belongs = :phase
          when Question
            belongs = :section
          when Annotation
            belongs = :question
          else
            raise ArgumentError,  _('obj should be a Phase, Section, Question, or Annotation')
        end

        if belongs == :template
          obj = obj.send(:deep_copy)
          obj.template = new_template
        else
          found = find_in_space(obj.send(belongs), new_template.phases)
          obj = obj.send(:deep_copy)
          obj.send("#{belongs}=", found)
        end
      end
      return obj
    end
  end

  private
    # Locates an object (e.g. phase, section, question, annotation) in a search_space
    # (e.g. phases/sections/questions/annotations) by comparing either the number method or
    # the org_id and text for annotations
    def find_in_space(obj, search_space)
      raise ArgumentError, _('The search_space does not respond to each') unless search_space.respond_to?(:each)
      raise ArgumentError, _('The search space does not have elements associated') unless search_space.length > 0

      if obj.is_a?(search_space.first.class)
        if obj.respond_to?(:number) # object is an instance of Phase, Section or Question
          return search_space.find{ |search| search.number == obj.number }
        elsif obj.respond_to?(:org_id) && obj.respond_to?(:text)  # object is an instance of Annotation
          return search_space.find{ |annotation| annotation.org_id == obj.org_id && annotation.text == obj.text }
        end
        return nil
      end

      case search_space.first
        when Phase
          number = obj.phase.number
          relation = :sections
        when Section
          number = obj.section.number
          relation = :questions
        when Question
          number = obj.question.number
          relation = :annotations
        else
          return nil
      end

      search_space = search_space.find{ |search| search.number == number }

      if search_space.present?
        return find_in_space(obj, search_space.send(relation))
      end
      return nil
    end
end
