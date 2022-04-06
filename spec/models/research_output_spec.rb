# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResearchOutput, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:plan).optional.touch(true) }
  end

  context 'validations' do
    before(:each) do
      @subject = create(:research_output, plan: create(:plan))
    end
    it { is_expected.to define_enum_for(:access).with_values(ResearchOutput.accesses.keys) }
    it { is_expected.to define_enum_for(:output_type).with_values(ResearchOutput.output_types.keys) }

    it { is_expected.to validate_presence_of(:output_type) }
    it { is_expected.to validate_presence_of(:access) }
    it { is_expected.to validate_presence_of(:title) }

    it {
      expect(@subject).to validate_uniqueness_of(:title).case_insensitive
                                                        .scoped_to(:plan_id)
                                                        .with_message('must be unique')
    }
    it {
      expect(@subject).to validate_uniqueness_of(:abbreviation).case_insensitive
                                                               .scoped_to(:plan_id)
                                                               .with_message('must be unique')
    }

    it "requires :output_type_description if :output_type is 'other'" do
      @subject.other!
      expect(@subject).to validate_presence_of(:output_type_description)
    end
    it "does not require :output_type_description if :output_type is 'dataset'" do
      @subject.dataset!
      expect(@subject).not_to validate_presence_of(:output_type_description)
    end
  end
  it 'factory builds a valid model' do
    expect(build(:research_output).valid?).to eql(true)
  end

  describe 'cascading deletes' do
    it 'does not delete associated plan' do
      model = create(:research_output, plan: create(:plan))
      plan = model.plan
      model.destroy
      expect(Plan.last).to eql(plan)
    end
  end

  context 'instance methods' do
    xit 'licenses should have tests once implemented' do
      true
    end
    xit 'repositories should have tests once implemented' do
      true
    end
    xit 'metadata_standards should have tests once implemented' do
      true
    end
    xit 'resource_types should have tests once implemented' do
      true
    end
  end
end
