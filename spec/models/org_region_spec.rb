require 'rails_helper'

RSpec.describe OrgRegion, type: :model do

  describe "associations" do
    
    it { is_expected.to belong_to :region }
    
    it { is_expected.to belong_to :org }    
    
  end
  
end
