# frozen_string_literal: true
require "rails_helper"

describe 'data_migration:documentationquality_documentationsoftware_to_string_array', type: :task do 
  it 'update documentation_quality_fragment' do 
    documentation_quality_fragment = create(:madmp_fragment, data: {
      "documentationSoftware" => "OPIDoR"
    })
    task.execute
    expect(documentation_quality_fragment).to have_updated
  end

end
