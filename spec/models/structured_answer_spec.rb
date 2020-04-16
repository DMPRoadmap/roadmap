require 'rails_helper'

RSpec.describe StructuredAnswer, type: :model do

  context "validations" do
    
    it { is_expected.to validate_presence_of(:structured_data_schema) }
    
  end

  context "associations" do

    it { is_expected.to belong_to :structured_data_schema }

    it { is_expected.to belong_to :answer }

  end 

  # describe ".update_parent_references" do

  #   it "should be called after a structured answer is created" do

  #     parent_answer = FactoryBot.create(:structured_answer, classname: "dmp")

  #     subject = Fragment::ResearchOutput.new

  #     subject.parent_id = parent_answer.id
  #     subject.dmp_id = parent_answer.id

  #     expect(subject).to receive(:update_parent_references)

  #     subject.save

  #   end
  # end
end
