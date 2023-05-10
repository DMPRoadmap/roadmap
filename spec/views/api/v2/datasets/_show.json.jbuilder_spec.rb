# frozen_string_literal: true

require 'rails_helper'

describe 'api/v2/datasets/_show.json.jbuilder' do
  context ':output is a ResearchOutput' do
    describe 'includes all of the dataset attributes' do
      before do
        @research_output = create(:research_output, plan: create(:plan))
        @presenter = Api::V1::ResearchOutputPresenter.new(output: @research_output)
      end

      describe 'base :dataset attributes' do
        before do
          render partial: 'api/v2/datasets/show', locals: { output: @research_output }
          @json = JSON.parse(rendered).with_indifferent_access
        end

        it 'includes :type' do
          expect(@json[:type]).to eql(@research_output.research_output_type)
        end

        it 'includes :title' do
          expect(@json[:title]).to eql(@research_output.title)
        end

        it 'includes :description' do
          expect(@json[:description]).to eql(@research_output.description)
        end

        it 'includes :personal_data' do
          val = Api::V1::ApiPresenter.boolean_to_yes_no_unknown(value: @research_output.personal_data)
          expect(@json[:personal_data]).to eql(val)
        end

        it 'includes :sensitive_data' do
          val = Api::V1::ApiPresenter.boolean_to_yes_no_unknown(value: @research_output.sensitive_data)
          expect(@json[:sensitive_data]).to eql(val)
        end

        it 'includes :issued' do
          expect(@json[:issued]).to eql(@research_output.release_date.to_formatted_s(:iso8601))
        end

        it 'includes :preservation_statement' do
          expect(@json[:preservation_statement]).to eql(@presenter.preservation_statement)
        end

        it 'includes :security_and_privacy' do
          expect(@json[:security_and_privacy]).to eql(@presenter.security_and_privacy)
        end

        it 'includes :data_quality_assurance' do
          expect(@json[:data_quality_assurance]).to eql(@presenter.data_quality_assurance)
        end
      end

      describe ':distribution' do
        before do
          @repo = @research_output.repositories.first
          @license = create(:license)
          @research_output.license_id = @license.id

          render partial: 'api/v2/datasets/show', locals: { output: @research_output }
          @json = JSON.parse(rendered).with_indifferent_access
        end

        it 'includes :distributions' do
          expect(@json[:distribution].any?).to be(true)
        end

        it 'includes :title' do
          expected = "Anticipated distribution for #{@research_output.title}"
          expect(@json[:distribution].first[:title]).to eql(expected)
        end

        it 'includes :byte_size' do
          expect(@json[:distribution].first[:byte_size]).to eql(@research_output.byte_size)
        end

        it 'includes :data_access' do
          expect(@json[:distribution].first[:data_access]).to eql(@research_output.access)
        end

        it 'includes host[:title]' do
          expect(@json[:distribution].first[:host][:title]).to eql(@repo.name)
        end

        it 'includes host[:description]' do
          expect(@json[:distribution].first[:host][:description]).to eql(@repo.description)
        end

        it 'includes host[:url]' do
          expect(@json[:distribution].first[:host][:url]).to eql(@repo.homepage)
        end

        it 'includes host[:dmproadmap_host_id]' do
          result = @json[:distribution].first[:host][:dmproadmap_host_id][:identifier]
          expect(result).to eql(@repo.uri)
        end

        it 'includes license[:license_ref]' do
          expect(@json[:distribution].first[:license].first[:license_ref]).to eql(@license.uri)
        end

        it 'includes license[:start_date]' do
          expected = @research_output.release_date.to_formatted_s(:iso8601)
          expect(@json[:distribution].first[:license].first[:start_date]).to eql(expected)
        end
      end

      describe ':metadata' do
        before do
          @standard = create(:metadata_standard)
          @research_output.metadata_standards << @standard

          render partial: 'api/v2/datasets/show', locals: { output: @research_output }
          @json = JSON.parse(rendered).with_indifferent_access
        end

        it 'includes :metadata' do
          expect(@json[:metadata].any?).to be(true)
        end

        it 'includes :description' do
          uri = @standard.uri
          metadata = @json[:metadata].select { |ms| ms[:metadata_standard_id][:identifier] == uri }
          expected = "#{@standard.title} - #{@standard.description}"
          expect(metadata.first[:description].start_with?(expected)).to be(true)
          expect(metadata.first[:metadata_standard_id].present?).to be(true)
          expect(metadata.first[:metadata_standard_id][:type]).to eql('url')
          expect(metadata.first[:metadata_standard_id][:identifier]).to eql(uri)
        end
      end

      describe ':technical_resources' do
        it 'is always an empty array because this has not been implemented' do
          render partial: 'api/v2/datasets/show', locals: { output: @research_output }
          @json = JSON.parse(rendered).with_indifferent_access
          expect(@json[:technical_resource].any?).to be(false)
        end
      end

      describe ':keyword' do
        it 'includes the ResearchDomain' do
          research_domain = create(:research_domain)
          @research_output.plan.research_domain_id = research_domain.id
          render partial: 'api/v2/datasets/show', locals: { output: @research_output }
          @json = JSON.parse(rendered).with_indifferent_access
          expect(@json[:keyword].any?).to be(true)
          expect(@json[:keyword].include?(research_domain.label))
          expect(@json[:keyword].include?("#{research_domain.identifier} - #{research_domain.label}"))
        end

        it 'is not included if no ResearchDomain is defined' do
          render partial: 'api/v2/datasets/show', locals: { output: @research_output }
          @json = JSON.parse(rendered).with_indifferent_access
          expect(@json[:keyword].present?).to be(false)
        end
      end
    end
  end

  context ':output is a Plan' do
    describe 'includes all of the dataset attributes' do
      before do
        @plan = create(:plan)
        @research_domain = create(:research_domain)
        @plan.research_domain_id = @research_domain.id

        render partial: 'api/v2/datasets/show', locals: { output: @plan }
        @json = JSON.parse(rendered).with_indifferent_access
      end

      it 'includes :type' do
        expect(@json[:type]).to eql('dataset')
      end

      it 'includes :title' do
        expect(@json[:title]).to eql('Generic dataset')
      end

      it 'includes :description' do
        expect(@json[:description]).to eql('No individual datasets have been defined for this DMP.')
      end

      describe ':keyword' do
        it 'includes the ResearchDomain' do
          expect(@json[:keyword].any?).to be(true)
          expect(@json[:keyword].include?(@research_domain.label))
          expect(@json[:keyword].include?("#{@research_domain.identifier} - #{@research_domain.label}"))
        end
      end
    end
  end
end
