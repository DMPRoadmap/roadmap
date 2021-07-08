# frozen_string_literal: true

require "rails_helper"

describe "shared/_org_autocomplete.html.erb" do

  before(:each) do
    @model = create(:plan)
  end

  context "local assignments" do
    describe "has defaults for all locals" do
      before(:each) do
        render partial: "shared/org_autocomplete"
      end

      it ":col_size defaults to nil" do
        expect(rendered.include?("class=\"col-md-\"")).to eql(true)
      end
      it ":default_org defaults to nil" do
        expect(rendered.include?("value=\"[null]\"")).to eql(true)
      end
      it ":required defaults to false" do
        expect(rendered.include?("aria-required=\"false\"")).to eql(true)
      end
      it ":funder_only defaults to false" do
        expect(rendered.include?("&amp;funder_only=false")).to eql(true)
      end
      it ":non_funder_only defaults to false" do
        expect(rendered.include?("&amp;non_funder_only=false")).to eql(true)
      end
      it ":known_only defaults to false" do
        expect(rendered.include?("&amp;known_only=false")).to eql(true)
      end
      it ":managed_only defaults to false" do
        expect(rendered.include?("&amp;managed_only=false")).to eql(true)
      end
      it ":allow_custom_org_entry defaults to true" do
        expect(rendered.include?("<conditional>")).to eql(true)
      end
      it ":label defaults to 'Organisation'" do
        expect(rendered.include?("Organisation")).to eql(true)
      end
      it ":namespace defaults to nil" do
        expect(rendered.include?("id=\"org_autocomplete_name\"")).to eql(true)
        expect(rendered.include?("name=\"org_autocomplete[not_in_list]\"")).to eql(true)
        expect(rendered.include?("id=\"org_autocomplete_user_entered_name\"")).to eql(true)
      end
    end

    describe "uses specified values for all locals" do
      before(:each) do
        @hash = {
          col_size: Faker::Number.number,
          default_org: build(:org),
          required: true,
          funder_only: true,
          non_funder_only: true,
          known_only: true,
          managed_only: true,
          label: Faker::Lorem.word,
          namespace: Faker::Lorem.word.downcase
        }
        render partial: "shared/org_autocomplete", locals: @hash
      end

      it "specified :col_size is used" do
        expect(rendered.include?("class=\"col-md-#{@hash[:col_size]}\"")).to eql(true)
      end
      it "specified :default_org is used" do
        expect(rendered.include?("value=\"#{@hash[:default_org].name}\"")).to eql(true)
      end
      it "specified :required is used" do
        expect(rendered.include?("aria-required=\"true\"")).to eql(true)
      end
      it "specified :funder_only is used" do
        expect(rendered.include?("&amp;funder_only=true")).to eql(true)
      end
      it "specified :non_funder_only is used" do
        expect(rendered.include?("&amp;non_funder_only=true")).to eql(true)
      end
      it "specified :known_only is used" do
        expect(rendered.include?("&amp;known_only=true")).to eql(true)
      end
      it "specified :managed_only is used" do
        expect(rendered.include?("&amp;managed_only=true")).to eql(true)
      end
      it "specified :allow_custom_org_entry is used" do
        expect(rendered.include?("<conditional>")).to eql(true)
      end
      it "specified :label is used" do
        expect(rendered.include?(@hash[:label])).to eql(true)
      end
      it "specified :namespace is used" do
        expect(rendered.include?("id=\"org_autocomplete_#{@hash[:namespace]}_name\"")).to eql(true)
        expect(rendered.include?("name=\"org_autocomplete[#{@hash[:namespace]}_not_in_list]\"")).to eql(true)
        expect(rendered.include?("id=\"org_autocomplete_#{@hash[:namespace]}_user_entered_name\"")).to eql(true)
      end
      it "unchangeable elements exist" do
        expect(rendered.include?("autocomplete-help")).to eql(true)
        expect(rendered.include?("ui-front")).to eql(true)
        expect(rendered.include?("id=\"org_autocomplete_crosswalk\"")).to eql(true)
      end
    end
  end

  it "does not display the custom Org checkbox if :allow_custom_org_entry is false" do
    render partial: "shared/org_autocomplete", locals: { allow_custom_org_entry: false }
    expect(rendered.include?("<conditional>")).to eql(false)
    expect(rendered.include?("name=\"org_autocomplete[not_in_list]\"")).to eql(false)
    expect(rendered.include?("id=\"org_autocomplete_user_entered_name\"")).to eql(false)
  end

end
