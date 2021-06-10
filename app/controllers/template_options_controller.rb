# frozen_string_literal: true

class TemplateOptionsController < ApplicationController

  after_action :verify_authorized

  # GET /template_options  (AJAX)
  # Collect all of the templates available for the org+funder combination
  def index
    org_id = (plan_params[:org_id] == "-1" ? "" : plan_params[:org_id])
    funder_id = (plan_params[:funder_id] == "-1" ? "" : plan_params[:funder_id])
    authorize Template.new, :template_options?
    @templates = []

    if org_id.present? || funder_id.present?
      unless funder_id.blank?
        # Load the funder's template(s) minus the default template (that gets swapped
        # in below if NO other templates are available)
        @templates = Template.latest_customizable
                             .where(org_id: funder_id, is_default: false)
        unless org_id.blank?
          # Swap out any organisational cusotmizations of a funder template
          @templates = @templates.map do |tmplt|
            customization = Template.published
                                    .latest_customized_version(tmplt.family_id,
                                                               org_id).first
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
      if funder_id.blank? || funder_id == org_id
        # Retrieve the Org's templates
        @templates << Template.published
                              .organisationally_visible
                              .where(org_id: org_id, customization_of: nil).to_a
      end
      
      # Include customizable funder templates
      @templates << funder_templates = Template.latest_customizable

      @templates = @templates.flatten.uniq
    end

    @templates = @templates.uniq.sort_by(&:title)

    # Always use the default template
    
    if Template.default.present?
      customization = Template.published
                        .latest_customized_version(Template.default.family_id,
                                                    org_id).first
      
      customization = Template.default unless customization

      @templates.select! { |t| t.id != customization.id }

      # We want the default template to appear at the beggining of the list
      @templates.unshift(customization)
    end
    
  end

  private

  def plan_params
    params.require(:plan).permit(:org_id, :funder_id)
  end

end
