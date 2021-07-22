# frozen_string_literal: true

class GuidancePresenter

  attr_accessor :plan
  attr_accessor :guidance_groups

  def initialize(plan)
    @plan = plan
    @guidance_groups = plan.guidance_groups.where(published: true)
  end

  def any?(org: nil, question: nil)
    if org.nil?
      return hashified_annotations? || hashified_guidance_groups? unless question.present?

      # check each annotation/guidance group for a response to this question
      # Would be nice not to have to crawl the entire list each time we want to know
      # this
      anno = orgs.reduce(false) do |found, o|
        found || guidance_annotations?(org: o, question: question)
      end
      return anno if anno

      return orgs.reduce(anno) do |found, o|
        found || guidance_groups_by_theme?(org: o, question: question)
      end
    end

    guidance_annotations?(org: org, question: question) ||
      guidance_groups_by_theme?(org: org, question: question)
  end
  # rubocop:enable

  # filters through the orgs with annotations and guidance groups to create a
  # set of tabs with display names and any guidance/annotations to show
  #
  # question  - The question to which guidance pretains
  #
  # Returns an array of tab hashes.  These
  def tablist(question)
    # start with orgs
    # filter into hash with annotation_presence, main_group presence, and
    display_tabs = []
    orgs.each do |org|
      annotations = guidance_annotations(org: org, question: question)
      groups = guidance_groups_by_theme(org: org, question: question)
      main_groups = groups.select { |group| group.optional_subset == false }
      subsets = groups.reject { |group| group.optional_subset == false }
      if annotations.present? || main_groups.present? # annotations and main group
        # Tab with org.abbreviation
        display_tabs << { name: org.abbreviation, groups: main_groups,
                          annotations: annotations }
      end
      next unless subsets.present?

      subsets.each_pair do |group, theme|
        display_tabs << { name: group.name.truncate(15), groups: { group => theme } }
      end
    end
    display_tabs
  end

  private

  # Returns an Array of orgs according to the guidance related to plan
  # Note the Array is sorted in the following order:
  # First funder org (if the template from the plan is a customization of another)
  # Second template owner's org
  # The orgs from every guidance group selected for this plan
  def orgs
    return @orgs if defined?(@orgs)

    @orgs = []
    orgs_from_annotations.each { |org| @orgs << org unless org_found(@orgs, org) }
    orgs_from_guidance_groups.each { |org| @orgs << org unless org_found(@orgs, org) }
    @orgs
  end

  def org_found(orgs, org)
    orgs.find do |lookup_org|
      lookup_org.id == org.id
    end.present?
  end

  # Returns true if exists any guidance_group applicable to the org and question passed
  def guidance_groups_by_theme?(org: nil, question: nil)
    return false unless question.respond_to?(:themes)
    return false unless hashified_guidance_groups.key?(org)

    result = guidance_groups_by_theme(org: org, question: question)
             .detect do |_gg, theme_hash|
      if theme_hash.present?
        theme_hash.detect { |_theme, guidances| guidances.present? }
      else
        false
      end
    end
    result.present?
  end

  # Returns true if exists any annotation applicable to the org and question passed
  def guidance_annotations?(org: nil, question: nil)
    return false unless question.respond_to?(:id)
    return false unless hashified_annotations.key?(org)

    hashified_annotations[org].find do |annotation|
      (annotation.question_id == question.id) && (annotation.type == "guidance")
    end.present?
  end

  # Returns a hash of guidance groups for an org and question passed with the following
  # structure:
  # { guidance_group: { theme: [guidance, ...], ... }, ... }
  def guidance_groups_by_theme(org: nil, question: nil)
    raise ArgumentError unless question.respond_to?(:themes)

    question = Question.includes(:themes).find(question.id)
    return {} unless hashified_guidance_groups.key?(org)

    hashified_guidance_groups[org].each_key.each_with_object({}) do |gg, acc|
      filtered_gg = hashified_guidance_groups[org][gg].each_key.each_with_object({}) do |theme, ac|
        next unless question.themes.include?(theme)

        ac[theme] = hashified_guidance_groups[org][gg][theme]
      end
      acc[gg] = filtered_gg if filtered_gg.present?
    end
  end

  # Returns a collection of annotations (type guidance) for an org and question passed
  def guidance_annotations(org: nil, question: nil)
    raise ArgumentError unless question.respond_to?(:id)
    return [] unless hashified_annotations.key?(org)

    hashified_annotations[org].select do |annotation|
      (annotation.question_id == question.id) && (annotation.type == "guidance")
    end
  end

  def orgs_from_guidance_groups
    return @orgs_from_guidance_groups if defined?(@orgs_from_guidance_groups)

    @orgs_from_guidance_groups = Org.joins(:guidance_groups)
                                    .where(guidance_groups: { id: guidance_groups.ids })
                                    .distinct("orgs.id")
    @orgs_from_guidance_groups
  end

  def orgs_from_annotations
    return @orgs_from_annotations if defined?(@orgs_from_annotations)

    @orgs_from_annotations = []
    if plan.template.customization_of.present?
      family_id = plan.template.customization_of
      @orgs_from_annotations << Template.find_by(family_id: family_id).org
    end
    @orgs_from_annotations << plan.template.org
    @orgs_from_annotations
  end

  def hashified_guidance_groups
    @hashified_guidance_groups ||= hashify_guidance_groups
  end

  def hashified_guidance_groups?
    result = hashified_guidance_groups.detect do |_org, gg_hash|
      if gg_hash.present?
        gg_hash.detect do |_gg, theme_hash|
          if theme_hash.present?
            theme_hash.detect { |_theme, guidances| guidances.present? }
          else
            false
          end
        end
      else
        false
      end
    end
    result.present?
  end

  def hashified_annotations
    @hashified_annotations ||= hashify_annotations
  end

  def hashified_annotations?
    hashified_annotations.detect { |_org, annotations| annotations.present? }.present?
  end

  # Hashifies guidance groups for a plan according to the distinct orgs into the
  # following structure:
  # { org: { guidance_group: { theme: [guidance, ...], ... }, ... }, ... }
  def hashify_guidance_groups
    hashified_guidances = hashify_guidances
    orgs_from_guidance_groups.each_with_object({}) do |org, acc|
      org_guidance_groups = hashified_guidances.each_key.select do |gg|
        gg.org_id == org.id
      end
      acc[org] = org_guidance_groups.each_with_object({}) do |gg, acc_inner|
        acc_inner[gg] = hashified_guidances[gg]
      end
    end
  end

  # Hashifies guidances from a collection of guidance_groups passed into the following
  # structure:
  # { guidance_group: { theme: [guidance, ...], ... }, ... }
  def hashify_guidances
    guidance_groups.each_with_object({}) do |gg, acc|
      themes = Theme.includes(:guidances)
                    .joins(:guidances)
                    .merge(Guidance.where(guidance_group_id: gg.id, published: true))
      acc[gg] = themes.each_with_object({}) do |theme, acc_inner|
        acc_inner[theme] = theme.guidances
      end
    end
  end

  def hashify_annotations
    orgs_from_annotations.each_with_object({}) do |org, acc|
      annotations = Annotation.where(org_id: org.id,
                                     question_id: plan.template.question_ids)
      acc[org] = annotations.select { |annotation| annotation.org_id = org.id }
    end
  end

end
