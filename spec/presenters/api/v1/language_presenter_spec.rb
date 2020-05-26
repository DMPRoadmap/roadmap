# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::LanguagePresenter do

  describe "#three_char_code(lang:)" do
    it "returns nil if the specified lang (as string) has no match" do
      expect(described_class.three_char_code(lang: "foo")).to eql(nil)
    end
    it "returns nil if the specified lang (as symbol) has no match" do
      expect(described_class.three_char_code(lang: :foo)).to eql(nil)
    end
    it "returns the 3 char code for the specified lang (as string)" do
      expect(described_class.three_char_code(lang: "en")).to eql("eng")
    end
    it "returns the 3 char code for the specified lang (as symbol)" do
      expect(described_class.three_char_code(lang: :en)).to eql("eng")
    end
    it "returns the 3 char code for the specified lang with region designation" do
      expect(described_class.three_char_code(lang: "en-UK")).to eql("eng")
    end
  end

end
