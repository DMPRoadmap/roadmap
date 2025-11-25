# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlansController, type: :controller do
  describe 'templates availability helpers' do
    before do
      @org = create(:org, :organisation, name: 'The User Org')
      @org_id = @org.id

      @org_template = create(:template, :default, :organisationally_visible, :published, org: @org,
                                                                                         title: 'Org Template')

      @funder1 = create(:org, :funder, name: 'Funder1 Org')
      @funder1_template = create(:template, :publicly_visible, :published,
                                 org: @funder1, title: 'Funder1 Template')

      @org_custom_funder1_template = create(:template, :organisationally_visible, :published,
                                            org: @org, customization_of: @funder1_template.family_id,
                                            title: 'Org Customised Funder1 Template')

      @funder2 = create(:org, :funder, name: 'Funder2 Org')
      @funder2_template = create(:template, :publicly_visible, :published, org: @funder2, title: 'Funder2 Template')

      @global_template = create(:template, :default, :publicly_visible, :published, title: 'Global Template')

      @other_org = create(:org, :organisation, name: 'The Other Org')
      @other_org_template = create(:template, :organisationally_visible, :published,
                                   org: @other_org, title: 'Other Org Template')
    end

    it 'returns a grouped hash containing the available templates' do
      grouped = controller.send(:templates_available_to_org_user, @org_id)
      expect(grouped).to be_a(Hash)
      puts "Grouped templates available to org id #{@org_id}: #{grouped.keys.inspect}"

      # flatten one level to inspect [title, id] entries across groups
      entries = grouped.values.flatten(1)
      puts entries.inspect
      # Available templates
      expect(entries).to include([@org_template.title, @org_template.id])
      expect(entries).to include([@org_custom_funder1_template.title, @org_custom_funder1_template.id])
      expect(entries).to include([@funder2_template.title, @funder2_template.id])
      expect(entries).to include([@global_template.title, @global_template.id])
      # Not available templates
      # As the org has already customised funder1_template, it should not appear in the available list
      expect(entries).not_to include([@funder1_template.title, @funder1_template.id])
      # Templates from other orgs should not appear if only organisationally visible
      expect(entries).not_to include([@other_org_template.title, @other_org_template.id])
    end

    it 'validates a template id that is available for the org' do
      expect(controller.send(:validate_template_available_to_org_user?, @org_template.id, @org_id)).to be true
      expect(controller.send(:validate_template_available_to_org_user?, @org_custom_funder1_template.id,
                             @org_id)).to be true
      expect(controller.send(:validate_template_available_to_org_user?, @funder2_template.id, @org_id)).to be true
      expect(controller.send(:validate_template_available_to_org_user?, @global_template.id, @org_id)).to be true
    end

    it 'returns false for a template id that is not available for the org' do
      # As the org has already customised funder1_template, it should not be available
      expect(controller.send(:validate_template_available_to_org_user?, @funder1_template.id, @org_id)).to be false
      # Templates from other orgs should not be available if only organisationally visible
      expect(controller.send(:validate_template_available_to_org_user?, @other_org_template.id, @org_id)).to be false
    end
  end
end
