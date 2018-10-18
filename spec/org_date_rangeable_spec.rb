require 'rails_helper'

RSpec.describe OrgDateRangeable do
  describe '.split_months_from_creation' do
    let(:org) do
      FactoryBot.create(:org, created_at: DateTime.new(2018,05,28,0,0,0))
    end

    it "starts at org's created_at" do
      expected_date = DateTime.new(2018,05,28,0,0,0)
      
      described_class.split_months_from_creation(org) do |start_date, end_date|
        expect(start_date).to eq(expected_date)
        break
      end
    end

    it "finishes at today's last month" do
      expected_date = DateTime.current.last_month.end_of_month.to_i
      actual_date = nil

      described_class.split_months_from_creation(org) do |start_date, end_date|
        actual_date = end_date.to_i
      end
      
      expect(actual_date).to eq(expected_date)
    end

   context 'when is an Enumerable' do
     subject { described_class.split_months_from_creation(org) }

     it 'responds to each method' do
       is_expected.to respond_to(:each)
     end

     it "starts at org's created_at" do
       first = subject.first
       start_date = org.created_at
       end_date = DateTime.new(2018,05,31,23,59,59).to_i

       expect(first[:start_date]).to eq(start_date)
       expect(first[:end_date].to_i).to eq(end_date)
     end
   end
  end
end
