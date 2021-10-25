# frozen_string_literal: true

require "rails_helper"

RSpec.describe Csvable do
  describe ".from_array_of_hashes" do
    let(:data) do
      [
        { column1: "value row1.1", column2: "value row1.2" },
        { column1: "value row2.1", column2: "value row2.2" },
        { column1: "value row3.1", column2: "value row3.2" }
      ]
    end

    it "returns empty string" do
      stringified_csv = described_class.from_array_of_hashes([])

      expect(stringified_csv).to be_empty
    end

    it "first row describes columns" do
      stringified_csv = described_class.from_array_of_hashes(data)

      header = /[^\n]+/.match(stringified_csv)[0]
      expect("Column1,Column2").to eq(header)
    end

    it "returns each hash within the array" do
      stringified_csv = described_class.from_array_of_hashes(data)

      output = <<~HERE
        Column1,Column2
        value row1.1,value row1.2
        value row2.1,value row2.2
        value row3.1,value row3.2
      HERE
      expect(stringified_csv).to eq(output)
    end
  end
end
