# frozen_string_literal: true

class TemplateOptionsController < ApplicationController

  after_action :verify_authorized

  # GET /template_options  (AJAX)
  # Collect all of the templates available for the org+funder combination
  def index
    org_hash = plan_params.fetch(:research_org_id, {})
    funder_hash = plan_params.fetch(:funder_id, {})
    authorize Template.new, :template_options?

    if org_hash.present?
      org = OrgSelection::HashToOrgService.to_org(hash: org_hash)
      org.save if org.new_record?
    end
    if funder_hash.present?
      funder = OrgSelection::HashToOrgService.to_org(hash: funder_hash)
      funder.save if funder.new_record?
    end

    @templates = []

    if org.present? && org.id.present? || (funder.present? && funder.id.present?)
      unless funder.id.blank?
        # Load the funder's template(s) minus the default template (that gets swapped
        # in below if NO other templates are available)
        @templates = Template.latest_customizable
                             .where(org_id: funder.id, is_default: false)
        unless org.id.blank?
          # Swap out any organisational cusotmizations of a funder template
          @templates = @templates.map do |tmplt|
            customization = Template.published
                                    .latest_customized_version(tmplt.family_id,
                                                               org.id).first
            # Only provide the customized version if its still up to date with the
            # funder template!
            if customization.present? && !customization.upgrade_customization?
              customization
            else
              tmplt
            end
          end
        end
      end

      # If the no funder was specified OR the funder matches the org
      if funder.id.blank? || funder.id == org.id
        # Retrieve the Org's templates
        @templates << Template.published
                              .organisationally_visible
                              .where(org_id: org.id, customization_of: nil).to_a
      end
      @templates = @templates.flatten.uniq
    end

    # If no templates were available use the default template
    if @templates.empty?
      if Template.default.present?
        customization = Template.published
                          .latest_customized_version(Template.default.family_id,
                                                     org&.id).first

        @templates << (customization.present? ? customization : Template.default)
      end
    end

p @templates.inspect

    @templates = @templates.sort_by(&:title)
  end

  private

  def plan_params
    params.require(:plan).permit(research_org_id: org_params,
                                 funder_id: org_params)
  end

  def org_params
    %i[id name sort_name url language abbreviation ror fundref weight score]
  end

end
