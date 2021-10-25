# frozen_string_literal: true

require "rails_helper"

describe "api/v1/_standard_response.json.jbuilder" do

  before(:each) do
    @application = Faker::Lorem.word
    @caller = Faker::Lorem.word
    @url = Faker::Internet.url
    @code = [200, 400, 404, 500].sample

    assign :application, @application
    assign :caller, @caller

    @response = OpenStruct.new(status: @code)
    @request = Net::HTTPGenericRequest.new("GET", nil, nil, @url)
  end

  describe "standard response items - Also the same as: GET /heartbeat" do

    before(:each) do
      render partial: "api/v1/standard_response",
             locals: { response: @response, request: @request }
      @json = JSON.parse(rendered).with_indifferent_access
    end

    it "includes the :application" do
      expect(@json[:application]).to eql(@application)
    end
    it "includes the :code" do
      expect(@json[:code]).to eql(@code)
    end
    it "includes the :message" do
      expect(@json[:message]).to eql(Rack::Utils::HTTP_STATUS_CODES[@code])
    end
    it "includes the :time" do
      expect(@json[:time].present?).to eql(true)
    end
    it ":time is in UTC format" do
      expect(Date.parse(@json[:time]).is_a?(Date)).to eql(true)
    end
    it "includes the :caller" do
      expect(@json[:caller]).to eql(@caller)
    end
    it "includes the :source" do
      expect(@json[:source].include?(@url)).to eql(true)
    end
    it "includes the :total_items" do
      expect(@json[:total_items]).to eql(0)
    end

  end

  context "responses with pagination" do

    describe "On the 1st page and there is only one page" do
      before(:each) do
        assign :page, 1
        assign :per_page, 3

        render partial: "api/v1/standard_response",
               locals: { response: @response, request: @request,
                         total_items: 3 }
        @json = JSON.parse(rendered).with_indifferent_access
      end

      it "shows the correct page number" do
        expect(@json[:page]).to eql(1)
      end
      it "includes the per_page number" do
        expect(@json[:per_page]).to eql(3)
      end
      it "includes the :total_items" do
        expect(@json[:total_items]).to eql(3)
      end
      it "does not show a 'prev' page link" do
        expect(@json[:prev].present?).to eql(false)
      end
      it "does not show a 'next' page link" do
        expect(@json[:prev].present?).to eql(false)
      end
    end

    describe "On the 1st page and there multiple pages" do
      before(:each) do
        assign :page, 1
        assign :per_page, 3

        render partial: "api/v1/standard_response",
               locals: { response: @response, request: @request,
                         total_items: 4 }
        @json = JSON.parse(rendered).with_indifferent_access
      end

      it "shows the correct page number" do
        expect(@json[:page]).to eql(1)
      end
      it "includes the per_page number" do
        expect(@json[:per_page]).to eql(3)
      end
      it "includes the :total_items" do
        expect(@json[:total_items]).to eql(4)
      end
      it "does not show a 'prev' page link" do
        expect(@json[:prev].present?).to eql(false)
      end
      it "does not show a 'next' page link" do
        expect(@json[:next].present?).to eql(true)
      end
    end

    describe "On the 2nd page and there more than 2 pages" do
      before(:each) do
        assign :page, 2
        assign :per_page, 3

        render partial: "api/v1/standard_response",
               locals: { response: @response, request: @request,
                         total_items: 7 }
        @json = JSON.parse(rendered).with_indifferent_access
      end

      it "shows the correct page number" do
        expect(@json[:page]).to eql(2)
      end
      it "includes the per_page number" do
        expect(@json[:per_page]).to eql(3)
      end
      it "includes the :total_items" do
        expect(@json[:total_items]).to eql(7)
      end
      it "does not show a 'prev' page link" do
        expect(@json[:prev].present?).to eql(true)
      end
      it "does not show a 'next' page link" do
        expect(@json[:next].present?).to eql(true)
      end
    end

    describe "On the last page" do
      before(:each) do
        assign :page, 2
        assign :per_page, 3

        render partial: "api/v1/standard_response",
               locals: { response: @response, request: @request,
                         total_items: 5 }
        @json = JSON.parse(rendered).with_indifferent_access
      end

      it "shows the correct page number" do
        expect(@json[:page]).to eql(2)
      end
      it "includes the per_page number" do
        expect(@json[:per_page]).to eql(3)
      end
      it "includes the :total_items" do
        expect(@json[:total_items]).to eql(5)
      end
      it "does not show a 'prev' page link" do
        expect(@json[:prev].present?).to eql(true)
      end
      it "does not show a 'next' page link" do
        expect(@json[:next].present?).to eql(false)
      end
    end

  end

end
