# frozen_string_literal: true

# Controller that determines which templates are displayed/selected for the user when
# they are creating a new plan
class TemplateOptionsController < ApplicationController
  include OrgSelectable

  after_action :verify_authorized

  # GET /template_options  (AJAX)
  # Collect all of the templates available for the org+funder combination
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def index
    authorize Plan

    research_org = process_org!(user: current_user)
    funder_org = process_org!(user: current_user, namespace: 'funder')

p "RESEARCH ORG: '#{research_org&.name}', FUNDER ORG: '#{funder_org&.name}'"
p Template.default.inspect
pp Template.where(is_default: true, published: true).last.inspect

    templates = []

    if research_org.present? || funder_org.present?
      if funder_org.present?
        # Load the funder's template(s) minus the default template (that gets swapped
        # in below if NO other templates are available)
        templates = Template.latest_customizable
                            .where(org_id: funder_org.id, is_default: false).to_a
        if research_org.present?
          # Swap out any organisational cusotmizations of a funder template
          templates = templates.map do |tmplt|
            customization = Template.published
                                    .latest_customized_version(tmplt.family_id, research_org.id)
                                    .first
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
      if funder_org.blank? || funder_org.id == research_org&.id
        # Retrieve the Org's templates
        templates << Template.published
                             .organisationally_visible
                             .where(org_id: research_org.id, customization_of: nil).to_a
      end
      templates = templates.flatten.uniq
    end

    # If no templates were available use the default template
    if templates.empty? && Template.default.present?
      customization = Template.published
                              .latest_customized_version(Template.default.family_id,
                                                         research_org&.id).first

      templates << (customization.present? ? customization : Template.default)
    end

pp templates.map(&:title)

    @templates = templates.sort_by(&:title)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  private

  def plan_params
    params.require(:plan).permit(:research_org_name, :funder_name)
  end
end
