require 'rails_helper'

RSpec.describe 'DMPTool custom home page', type: :request do

  describe '#render_home_page' do

    context 'statistics' do

      let!(:other_org) { create(:org, is_other: true) }

      it 'has the correct number of users' do
        (0..4).each { create(:user, org: other_org) }
        get root_path
        expect(assigns(:stats)[:user_count]).to eql(5)
      end

      it 'has the correct number of plans' do
        (0..4).each { create(:plan) }
        get root_path
        expect(assigns(:stats)[:completed_plan_count]).to eql(5)
      end

      it 'has the correct number of orgs' do
        (0..4).each { create(:org, is_other: false) }
        get root_path
        expect(assigns(:stats)[:institution_count]).to eql(5)
      end

    end

    context 'top_templates' do

      let!(:org) { create(:org, is_other: false) }
      let!(:templates) { (0..12).map { create(:template, :published, phases: 1, org: org) } }

      before do
        templates.each_with_index do |tmplt, i|
          i.times do
            create(:plan, :publicly_visible, :creator, template: tmplt,
                          created_at: Date.today-1, complete: i.odd?)
          end
        end
      end

      it 'has the correct number of templates' do
        get root_path
        expect(assigns(:top_5).length).to eql(5)
      end

      it 'includes the correct templates' do
        get root_path
        # The Top 5 template count should be based on the number of plans
        ids = Plan.group(:template_id).order("count_id DESC").count(:id).keys
        ids[0..4].each do |id|
          expect(assigns(:top_5).include?(Template.find(id).title)).to eql(true)
        end
      end

    end

    context 'rss' do
      # Skipping this test since it relies on an external WP blog. We could stub
    end

  end

end
