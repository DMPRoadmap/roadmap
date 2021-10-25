# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::PaginationPresenter do

  describe "#url_without_pagination" do
    before(:each) do
      @url = Faker::Internet.url
    end

    it "returns nil if no url was specified" do
      presenter = described_class.new(current_url: nil, per_page: 2,
                                      total_items: 1, current_page: 1)
      expect(presenter.url_without_pagination).to eql(nil)
    end
    it "removes per_page from the query string" do
      target = "#{@url}?per_page=2"
      presenter = described_class.new(current_url: target, per_page: 2,
                                      total_items: 1, current_page: 1)
      rslt = presenter.url_without_pagination.include?("per_page=2")
      expect(rslt).to eql(false)
    end
    it "removes page from the query string" do
      target = "#{@url}?page=2"
      presenter = described_class.new(current_url: target, per_page: 2,
                                      total_items: 1, current_page: 1)
      rslt = presenter.url_without_pagination.include?("page=2")
      expect(rslt).to eql(false)
    end
    it "retains other query string items if there were no pagination ones" do
      target = "#{@url}?other=true"
      presenter = described_class.new(current_url: target, per_page: 2,
                                      total_items: 1, current_page: 1)
      rslt = presenter.url_without_pagination.include?("other=true")
      expect(rslt).to eql(true)
    end
    it "retains other query string items if it removed pagination ones" do
      target = "#{@url}?per_page=2&other=true"
      presenter = described_class.new(current_url: target, per_page: 2,
                                      total_items: 1, current_page: 1)
      rslt = presenter.url_without_pagination.include?("other=true")
      expect(rslt).to eql(true)
    end
    it "ends with a '&' if there were query string items" do
      target = "#{@url}?per_page=2&other=true"
      presenter = described_class.new(current_url: target, per_page: 2,
                                      total_items: 1, current_page: 1)
      rslt = presenter.url_without_pagination.end_with?("&")
      expect(rslt).to eql(true)
    end
    it "ends with a '?' if there were no query string items" do
      presenter = described_class.new(current_url: @url, per_page: 2,
                                      total_items: 1, current_page: 1)
      rslt = presenter.url_without_pagination.end_with?("?")
      expect(rslt).to eql(true)
    end
    it "ends with a '?' if there were only pagination items in query string" do
      target = "#{@url}?page=2"
      presenter = described_class.new(current_url: target, per_page: 2,
                                      total_items: 1, current_page: 1)
      rslt = presenter.url_without_pagination.end_with?("?")
      expect(rslt).to eql(true)
    end
  end

  describe "#prev_page?" do
    it "returns false if we are on page 1" do
      presenter = described_class.new(current_url: nil, per_page: 2,
                                      total_items: 4, current_page: 1)
      expect(presenter.prev_page?).to eql(false)
    end
    it "returns false if there is only 1 page" do
      presenter = described_class.new(current_url: nil, per_page: 2,
                                      total_items: 2, current_page: 2)
      expect(presenter.prev_page?).to eql(false)
    end
    it "returns true if more than 1 page and we are not on page 1" do
      presenter = described_class.new(current_url: nil, per_page: 2,
                                      total_items: 4, current_page: 2)
      expect(presenter.prev_page?).to eql(true)
    end
  end

  describe "#next_page?" do
    it "returns false if we are on the last page" do
      presenter = described_class.new(current_url: nil, per_page: 2,
                                      total_items: 4, current_page: 2)
      expect(presenter.next_page?).to eql(false)
    end
    it "returns false if there is only 1 page" do
      presenter = described_class.new(current_url: nil, per_page: 2,
                                      total_items: 2, current_page: 1)
      expect(presenter.next_page?).to eql(false)
    end
    it "returns true if more than 1 page and we are not on last page" do
      presenter = described_class.new(current_url: nil, per_page: 2,
                                      total_items: 4, current_page: 1)
      expect(presenter.next_page?).to eql(true)
    end
  end

  describe "#prev_page_link" do
    before(:each) do
      url = "#{Faker::Internet.url}?other=true"
      @presenter = described_class.new(current_url: url, per_page: 2,
                                       total_items: 4, current_page: 2)
    end

    it "includes per_page in the query string" do
      expect(@presenter.prev_page_link.include?("per_page=2")).to eql(true)
    end
    it "includes shows the correct page number" do
      expect(@presenter.prev_page_link.include?("page=1")).to eql(true)
    end
    it "retains other query params" do
      expect(@presenter.prev_page_link.include?("other=true")).to eql(true)
    end
  end

  describe "#next_page_link" do
    before(:each) do
      url = "#{Faker::Internet.url}?other=true"
      @presenter = described_class.new(current_url: url, per_page: 2,
                                       total_items: 4, current_page: 1)
    end

    it "includes per_page in the query string" do
      expect(@presenter.next_page_link.include?("per_page=2")).to eql(true)
    end
    it "includes shows the correct page number" do
      expect(@presenter.next_page_link.include?("page=2")).to eql(true)
    end
    it "retains other query params" do
      expect(@presenter.next_page_link.include?("other=true")).to eql(true)
    end
  end

  context "private methods" do

    describe "#total_pages" do
      it "returns 1 if total_items is missing" do
        presenter = described_class.new(current_url: nil, per_page: 2,
                                        total_items: nil)
        expect(presenter.send(:total_pages)).to eql(1)
      end
      it "returns 1 if per_page is missing" do
        presenter = described_class.new(current_url: nil, per_page: nil,
                                        total_items: 4)
        expect(presenter.send(:total_pages)).to eql(1)
      end
      it "returns 1 if total_items is <= 0" do
        presenter = described_class.new(current_url: nil, per_page: 2,
                                        total_items: 0)
        expect(presenter.send(:total_pages)).to eql(1)
      end
      it "returns 1 if per_page is <= 0" do
        presenter = described_class.new(current_url: nil, per_page: 0,
                                        total_items: 4)
        expect(presenter.send(:total_pages)).to eql(1)
      end
      it "returns the total_items / per_page" do
        presenter = described_class.new(current_url: nil, per_page: 2,
                                        total_items: 4)
        expect(presenter.send(:total_pages)).to eql(2)
      end
      it "rounds up" do
        presenter = described_class.new(current_url: nil, per_page: 3,
                                        total_items: 4)
        expect(presenter.send(:total_pages)).to eql(2)
      end
    end

  end

end
