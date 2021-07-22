# frozen_string_literal: true

module Versionable

  private

  # Takes in a Template, phase, Section, Question, or Annotaion
  # IF the template is published, generates a new template
  # finds the passed object in the new template
  #
  # obj - Template, Phase, Section, Question, Annotation
  #
  # Returns ActiveRecord::Base
  def get_modifiable(obj)
    if obj.respond_to?(:template)
      template = obj.template
    elsif obj.is_a?(Template)
      template = obj
    else
      raise ArgumentError,
            _("obj should be a Template, Phase, Section, Question, or Annotation")
    end

    # raises RuntimeError if template is not latest
    new_template = Template.find_or_generate_version!(template)

    if new_template != template
      obj = if obj.is_a?(Template)
              new_template
            else
              find_in_space(obj, new_template.phases)
            end
    end
    obj
  end

  ##
  # Takes in a phase, Section, Question, or Annotation which is newly
  # generated and returns a modifiable version of that object
  # NOTE: the obj passed is still not saved however it should belongs to a
  # parent already
  # rubocop:disable Metrics/MethodLength
  def get_new(obj)
    unless obj.respond_to?(:template)
      raise ArgumentError,
            _("obj should be a Phase, Section, Question, or Annotation")
    end

    template = obj.template
    # raises RuntimeError if template is not latest
    new_template = Template.find_or_generate_version!(template)

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
        raise ArgumentError,
              _("obj should be a Phase, Section, Question, or Annotation")
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
    obj
  end
  # rubocop:enable Metrics/MethodLength

  # Locates an object (e.g. phase, section, question, annotation) in a
  # search_space
  # (e.g. phases/sections/questions/annotations) by comparing either the number
  # method or the org_id and text for annotations
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def find_in_space(obj, search_space)
    unless search_space.respond_to?(:each)
      raise ArgumentError, _("The search_space does not respond to each")
    end

    if search_space.empty?
      raise ArgumentError,
            _("The search space does not have elements associated")
    end

    if obj.is_a?(search_space.first.class)
      # object is an instance of Phase, Section or Question
      return search_space.find { |search| search.number == obj.number } if obj.respond_to?(:number)

      # object is an instance of Annotation
      if obj.respond_to?(:org_id) && obj.respond_to?(:text)
        return search_space.find do |annotation|
          annotation.org_id == obj.org_id && annotation.text == obj.text
        end
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
      relation = if obj.is_a?(QuestionOption)
                   :question_options
                 else
                   :annotations
                 end
    else
      return nil
    end

    search_space = search_space.find { |search| search.number == number }

    return find_in_space(obj, search_space.send(relation)) if search_space.present?

    nil
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable

end
