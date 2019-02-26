require 'rails_helper'

RSpec.describe Region, type: :model do

  describe "associations" do
    
    it { is_expected.to have_many :org_regions }
    
    it { is_expected.to have_many(:orgs).through(:org_regions) }
    
  end
  
end
