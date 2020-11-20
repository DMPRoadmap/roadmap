# frozen_string_literal: true

require "spec_helper"

RSpec.describe SectionSorter, type: :model do

  StubSection = Struct.new(:number, :modifiable, :id) do

    alias_method :modifiable?, :modifiable

    def unmodifiable?
      !modifiable?
    end

    def has_number?(value)
      number == value
    end

    def has_id?(value)
      id == value
    end

  end

  describe "#sort!" do

    let!(:sections_array) do
      [
        StubSection.new(1, true, 105),
        StubSection.new(2, false, 108),
        StubSection.new(3, false, 111),
        StubSection.new(4, true, 19),
        StubSection.new(5, false, 1009),
        StubSection.new(6, true, 999)
      ].shuffle
    end

    subject { SectionSorter.new(*sections_array).sort! }

    it "returns an Array" do
      expect(subject).to be_an_instance_of(Array)
    end

    it "moves the prefix section to the front" do
      expect(subject.first).to have_number(1)
    end

    it "groups unmodifiable sections together" do
      expect(subject[1..3].map(&:number)).to eql([2, 3, 5])
    end

    it "groups modifiable sections together, last" do
      expect(subject[4..5].map(&:number)).to eql([4, 6])
    end

    context "when duplicate prefix exists" do

      let!(:sections_array) do
        [
          StubSection.new(1, false, 12),
          StubSection.new(1, true, 34),
          StubSection.new(2, false, 54),
          StubSection.new(3, false, 199),
          StubSection.new(4, true, 84),
          StubSection.new(5, false, 129),
          StubSection.new(6, true, 555)
        ].shuffle
      end

      it "moves the modifiable one to the front" do
        expect(subject.first).to have_id(34)
        expect(subject.first).to be_modifiable
      end

      it "moves the unmodifiable one to the second position" do
        expect(subject.second).to have_id(12)
        expect(subject.second).to be_unmodifiable
      end

    end

    context "when duplicate section exists" do

      let!(:sections_array) do
        [
          StubSection.new(1, true, 34),
          StubSection.new(2, false, 54),
          StubSection.new(3, true, 199),
          StubSection.new(3, true, 205),
          StubSection.new(3, true, 84)
        ].shuffle
      end

      it "sorts the duplicates by id" do
        expect(subject[2]).to have_id(84)
        expect(subject[3]).to have_id(199)
        expect(subject[4]).to have_id(205)
      end

    end

    context "when all sections are modifiable" do

      let!(:sections_array) do
        [
          StubSection.new(1, true, 105),
          StubSection.new(2, true, 108),
          StubSection.new(3, true, 111),
          StubSection.new(4, true, 19),
          StubSection.new(5, true, 1009),
          StubSection.new(5, true, 999)
        ].shuffle
      end

      it "sorts all sections by number" do
        expect(subject.map(&:number)).to eql([1, 2, 3, 4, 5, 5])
      end

      it "sorts duplicates by id" do
        expect(subject.last).to have_id(1009)
      end

    end

    context "when all sections are unmodifiable" do

      let!(:sections_array) do
        [
          StubSection.new(1, false, 105),
          StubSection.new(2, false, 108),
          StubSection.new(3, false, 111),
          StubSection.new(4, false, 109),
          StubSection.new(4, false, 10),
          StubSection.new(5, false, 999)
        ].shuffle
      end

      it "sorts all sections by number" do
        expect(subject.map(&:number)).to eql([1, 2, 3, 4, 4, 5])
      end

      it "sorts duplicates by id" do
        expect(subject[4]).to have_id(109)
      end

    end

  end

end
