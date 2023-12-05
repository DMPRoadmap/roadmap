# frozen_string_literal: true

module Dmpopidor
  # Customized code for TemplateOptionsController
  module TemplateOptionsController
    # CHANGES : - Default template should appear in template lists
    #           - Added Template Context support
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def index
      org_hash = plan_params.fetch(:research_org_id, {})
      funder_hash = plan_params.fetch(:funder_id, {})
      template_context = ::Template.contexts[plan_params[:context]] || 'research_project'
      authorize ::Template.new, :template_options?

      org = org_from_params(params_in: { org_id: org_hash.to_json }) if org_hash.present?
      funder = org_from_params(params_in: { org_id: funder_hash.to_json }) if funder_hash.present?

      @templates = []

      if (org.present? && !org.new_record?) ||
         (funder.present? && !funder.new_record?)
        if funder.present? && !funder.new_record?
          @templates = ::Template.latest_customizable
                                 .where(org_id: funder.id).to_a
          if org.present? && !org.new_record?
            # Swap out any organisational customizations of a funder template
            @templates = @templates.map do |tmplt|
              customization = ::Template.published
                                        .latest_customized_version(tmplt.family_id,
                                                                   org.id).first
              # Only provide the customized version if its still up to date with the
              # funder template!
              # rubocop:disable Metrics/BlockNesting
              if customization.present? && !customization.upgrade_customization?
                customization
              else
                tmplt
              end
              # rubocop:enable Metrics/BlockNesting
            end
          end
        end

        # If the no funder was specified OR the funder matches the org
        if funder.blank? || funder.id == org&.id
          # Retrieve the Org's templates
          @templates << ::Template.published.where(org_id: org&.id, context: template_context).to_a
        end

      else
        @templates = ::Template.published
                               .where(org_id: current_user.org.id, context: template_context).to_a
      end

      @templates = @templates.flatten.uniq

      @templates.each do |template|
        template.title += " (#{_('Customized by ')} #{template.org.name})" if template.customization_of.present?
      end

      @templates = @templates.sort_by(&:title)
      res = @templates.map do |template|
        {
          id: template.id,
          locale: template.locale,
          title: template.title,
          description: template.description || '',
          structured: template.structured?
        }
      end.as_json()
      render json: res
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def default
      default_template = ::Template.default
      authorize ::Template.new, :template_options?

      render json: {
        id: default_template.id,
        title: default_template.title,
        locale: default_template.locale,
        description: default_template.description || '',
        structured: default_template.structured?
      }
    end
  end
end
