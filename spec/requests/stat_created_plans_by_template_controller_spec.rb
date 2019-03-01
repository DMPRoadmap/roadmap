require 'rails_helper'

RSpec.describe '/stat_created_plan_by_template', type: :request do
  def parsed_response
    JSON.parse(response.body, symbolize_names: true)
  end

  describe '#index' do
    let(:path) { '/stat_created_plans_by_template' }

    it 'redirects when non-authorized user' do
      get path

      expect(response).to have_http_status(:redirect)
    end

    context 'when org_admin user' do
      let(:org) { create(:org) }
      let(:org_admin) { create(:user, :org_admin, org: org) }
      before(:each) do
        sign_in(org_admin)
      end

      it 'returns 200 status' do
        get path

        expect(response.content_type).to eq('application/json')
        expect(response).to have_http_status(:ok)
      end

      context 'when there are no stats' do
        it 'returns empty' do
          get path

          expect(parsed_response).to eq([])
        end

        it 'returns empty csv file' do
          get "#{path}.csv"

          expect(response.content_type).to eq('text/csv')
          expect(response.body).to eq('')
        end
      end

      context "when there are stats" do
        before do
          create(:stat_created_plan, date: '2018-07-31', count: 5, org: org, details: { by_template: [{ name: 'Template1', count: 3 }, { name: 'Template2', count: 2 }]})
          create(:stat_created_plan, date: '2018-08-31', count: 10, org: org, details: { by_template: [{ name: 'Template1', count: 6 }, { name: 'Template2', count: 4 }]})
          create(:stat_created_plan, date: '2018-09-30', count: 10, org: org, details: { by_template: [{ name: 'Template1', count: 6 }, { name: 'Template2', count: 4 }]})
        end

        it "returns all stats" do
          get path

          expect(parsed_response).to eq([
            { date: '2018-09-30', count: 10, by_template: [{ name: 'Template1', count: 6 }, { name: 'Template2', count: 4 }]},
            { date: '2018-08-31', count: 10, by_template: [{ name: 'Template1', count: 6 }, { name: 'Template2', count: 4 }]},
            { date: '2018-07-31', count: 5, by_template: [{ name: 'Template1', count: 3 }, { name: 'Template2', count: 2 }]}
          ])
        end

        it 'returns all stats csv formatted' do
          get "#{path}.csv"

          expected_csv = <<~HERE
          Date,Template1,Template2,Count
          2018-09-30,6,4,10
          2018-08-31,6,4,10
          2018-07-31,3,2,5
          HERE
          expect(response.body).to eq(expected_csv)
        end

        it 'returns stats for start_date and end_date passed' do
          get path, { start_date: '2018-08-31', end_date: '2018-09-30' }

          expect(parsed_response).to eq([
            { date: '2018-09-30', count: 10, by_template: [{ name: 'Template1', count: 6 }, { name: 'Template2', count: 4 }]},
            { date: '2018-08-31', count: 10, by_template: [{ name: 'Template1', count: 6 }, { name: 'Template2', count: 4 }]}
          ])
        end

        it 'returns stats from start_date passed' do
          get path, { start_date: '2018-08-31' }

          expect(parsed_response).to eq([
            { date: '2018-09-30', count: 10, by_template: [{ name: 'Template1', count: 6 }, { name: 'Template2', count: 4 }]},
            { date: '2018-08-31', count: 10, by_template: [{ name: 'Template1', count: 6 }, { name: 'Template2', count: 4 }]},
          ])
        end

        it 'returns stats until end_date passed' do
          get path, { end_date: '2018-08-31' }

          expect(parsed_response).to eq([
            { date: '2018-08-31', count: 10, by_template: [{ name: 'Template1', count: 6 }, { name: 'Template2', count: 4 }]},
            { date: '2018-07-31', count: 5, by_template: [{ name: 'Template1', count: 3 }, { name: 'Template2', count: 2 }]}
          ])
        end
      end
    end
  end
end
