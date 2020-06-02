require 'rails_helper'

RSpec.describe ResearchOutput, type: :model do

    context "validations" do

        subject { build(:research_output) }

        it { is_expected.to validate_presence_of(:abbreviation) }

        it { is_expected.to validate_presence_of(:fullname) }
        
        it { is_expected.to validate_presence_of(:plan) }

        it { is_expected.to validate_presence_of(:type) }

    end

    context "associations" do 

        it { is_expected.to belong_to :plan }

        it { is_expected.to belong_to :type }

        it { is_expected.to have_many :answers }

    end

    describe ".main?" do

        context "when order is equal to 1" do
            let!(:research_output) { create(:research_output, order: 1)}

            subject { research_output }

            it { expect(subject.main?).to eql(true) }
        end

        context "when order is not equal to 1" do
            let!(:research_output) { create(:research_output, order: 2)}

            subject { research_output }

            it { expect(subject.main?).not_to eql(true) }
        end

    end



    describe ".deep_copy" do
        let!(:research_output) { create(:research_output) }

        subject { ResearchOutput.deep_copy(research_output) }

        it "creates a new record" do
            expect(subject).not_to eql(research_output)
        end

        it "copies the abbreviation attribute" do
            expect(subject.abbreviation).to eql(research_output.abbreviation)
        end

        it "copies the fullname attribute" do
            expect(subject.fullname).to eql(research_output.fullname)
        end

        it "copies the is_default attribute" do
            expect(subject.is_default).to eql(research_output.is_default)
        end

        it "copies the pid attribute" do
            expect(subject.pid).to eql(research_output.pid)
        end

    end


    describe "destroy" do
        let!(:research_output) { create(:research_output) }

        let!(:answer) { create(:answer)}


        it "destroys the answer when the research output is destroyed" do 
            research_output.answers << answer

            expect { research_output.destroy }.to change { Answer.count }
        end

    end
end