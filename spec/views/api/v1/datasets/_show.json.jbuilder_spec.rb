# frozen_string_literal: true

require 'rails_helper'

describe 'api/v1/datasets/_show.json.jbuilder' do
  context 'config has disabled madmp options' do
    before do
      @plan = create(:plan)
      @output = create(:research_output, plan: @plan)
    end

    it 'does not include :preservation_statement if config is false' do
      Rails.configuration.x.madmp.extract_preservation_statements_from_themed_questions = false
      render partial: 'api/v1/datasets/show', locals: { output: @output }
      json = JSON.parse(rendered).with_indifferent_access
      expect(json[:preservation_statement]).to eql('')
    end

    it 'does not include :security_and_privacy if config is false' do
      Rails.configuration.x.madmp.extract_security_privacy_statements_from_themed_questions = false
      render partial: 'api/v1/datasets/show', locals: { output: @output }
      json = JSON.parse(rendered).with_indifferent_access
      expect(json[:security_and_privacy]).to eql([])
    end

    it 'does not include :data_quality_assurance if config is false' do
      Rails.configuration.x.madmp.extract_data_quality_statements_from_themed_questions = false
      render partial: 'api/v1/datasets/show', locals: { output: @output }
      json = JSON.parse(rendered).with_indifferent_access
      expect(json[:data_quality_assurance]).to eql('')
    end
  end

  context 'config has enabled madmp options' do
    before do
      Rails.configuration.x.madmp.extract_preservation_statements_from_themed_questions = true
      Rails.configuration.x.madmp.extract_security_privacy_statements_from_themed_questions = true
      Rails.configuration.x.madmp.extract_data_quality_statements_from_themed_questions = true

      @plan = create(:plan)
      @output = create(:research_output, plan: @plan)
      render partial: 'api/v1/datasets/show', locals: { output: @output }
      @json = JSON.parse(rendered).with_indifferent_access
    end

    describe 'includes all of the dataset attributes' do
      it 'includes :type' do
        expect(@json[:type]).to eql(@output.research_output_type)
      end

      it 'includes :title' do
        expect(@json[:title]).to eql(@output.title)
      end

      it 'includes :description' do
        expect(@json[:description]).to eql(@output.description)
      end

      it 'includes :personal_data' do
        expected = Api::V1::ApiPresenter.boolean_to_yes_no_unknown(value: @output.personal_data)
        expect(@json[:personal_data]).to eql(expected)
      end

      it 'includes :sensitive_data' do
        expected = Api::V1::ApiPresenter.boolean_to_yes_no_unknown(value: @output.sensitive_data)
        expect(@json[:sensitive_data]).to eql(expected)
      end

      it 'includes :issued' do
        expect(@json[:issued]).to eql(@output.release_date&.to_formatted_s(:iso8601))
      end

      it 'includes :dataset_id' do
        expect(@json[:dataset_id][:type]).to eql('other')
        expect(@json[:dataset_id][:identifier]).to eql(@output.id.to_s)
      end

      context ':distribution info' do
        before do
          @distribution = @json[:distribution].first
        end

        it 'includes :byte_size' do
          expect(@distribution[:byte_size]).to eql(@output.byte_size)
        end

        it 'includes :data_access' do
          expect(@distribution[:data_access]).to eql(@output.access)
        end

        it 'includes :format' do
          expect(@distribution[:format]).to be_nil
        end
      end

      it 'includes :metadata' do
        expect(@json[:metadata]).not_to eql([])
        expect(@json[:metadata].first[:description].present?).to be(true)
        expect(@json[:metadata].first[:metadata_standard_id].present?).to be(true)
        expect(@json[:metadata].first[:metadata_standard_id][:type].present?).to be(true)
        expect(@json[:metadata].first[:metadata_standard_id][:identifier].present?).to be(true)
      end

      it 'includes :technical_resources' do
        expect(@json[:technical_resources]).to be_nil
      end
    end

    describe 'includes all of the repository info as attributes' do
      before do
        @host = @json[:distribution].first[:host]
        @expected = @output.repositories.last
      end

      it 'includes :title' do
        expect(@host[:title]).to eql(@expected.name)
      end

      it 'includes :description' do
        expect(@host[:description]).to eql(@expected.description)
      end

      it 'includes :url' do
        expect(@host[:url]).to eql(@expected.homepage)
      end

      it 'includes :dmproadmap_host_id' do
        expect(@host[:dmproadmap_host_id][:type]).to eql('url')
        expect(@host[:dmproadmap_host_id][:identifier]).to eql(@expected.uri)
      end
    end

    describe 'includes all of the themed question/answers as attributes' do
      it 'includes :preservation_statement' do
        expect(@json[:preservation_statement]).to eql('')
      end

      it 'includes :security_and_privacy' do
        expect(@json[:security_and_privacy]).to eql([])
      end

      it 'includes :data_quality_assurance' do
        expect(@json[:data_quality_assurance]).to eql('')
      end
    end
  end
end
