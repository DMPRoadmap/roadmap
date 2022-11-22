# frozen_string_literal: true

require 'rails_helper'

describe 'shared/_org_autocomplete.html.erb' do
  before do
    @model = create(:plan)
  end

  context 'local assignments' do
    describe 'has defaults for all locals' do
      before do
        Rails.configuration.x.application.restrict_orgs = false
        render partial: 'shared/org_autocomplete'
      end

      it ':default_org defaults to nil' do
        expect(rendered.include?('autocomplete-default-selection-')).to be(false)
      end

      it ':required defaults to false' do
        expect(rendered.include?('aria-required="false"')).to be(true)
      end

      it ':funder_only defaults to false' do
        expect(rendered.include?('&amp;funder_only=false')).to be(true)
      end

      it ':non_funder_only defaults to false' do
        expect(rendered.include?('&amp;non_funder_only=false')).to be(true)
      end

      it ':known_only defaults to false' do
        expect(rendered.include?('&amp;known_only=false')).to be(true)
      end

      it ':unknown_only defaults to false' do
        expect(rendered.include?('&amp;unknown_only=false')).to be(true)
      end

      it ':managed_only defaults to false' do
        expect(rendered.include?('&amp;managed_only=false')).to be(true)
      end

      it ':allow_custom_org_entry defaults to true' do
        expect(rendered.include?('<conditional>')).to be(true)
      end

      it ":label defaults to 'Organisation'" do
        expect(rendered.include?('Organisation')).to be(true)
      end

      it ':namespace defaults to nil' do
        expect(rendered.include?('id="org"')).to be(true)
        expect(rendered.include?('id="org_autocomplete_name"')).to be(true)
        expect(rendered.include?('class="c-textfield__invalid-description')).to be(true)
        expect(rendered.include?('name="org_autocomplete[not_in_list]"')).to be(true)
        expect(rendered.include?('id="org_autocomplete_user_entered_name"')).to be(true)
      end
    end

    describe 'uses specified values for all locals' do
      before do
        Rails.configuration.x.application.restrict_orgs = false
        @hash = {
          col_size: Faker::Number.number,
          default_org: create(:org),
          required: true,
          funder_only: true,
          non_funder_only: true,
          known_only: true,
          managed_only: true,
          label: Faker::Lorem.word,
          namespace: Faker::Lorem.word.downcase
        }
        render partial: 'shared/org_autocomplete', locals: @hash
      end

      it 'specified :default_org is used' do
        expected = "value=\"#{CGI.escapeHTML(@hash[:default_org].name)}\""
        expect(rendered.include?(expected)).to be(true)
        expect(rendered.include?('autocomplete-default-selection-')).to be(true)
      end

      it 'specified :required is used' do
        expect(rendered.include?('aria-required="true"')).to be(true)
      end

      it 'specified :funder_only is used' do
        expect(rendered.include?('&amp;funder_only=true')).to be(true)
      end

      it 'specified :non_funder_only is used' do
        expect(rendered.include?('&amp;non_funder_only=true')).to be(true)
        expect(rendered.include?('<conditional>')).to be(false)
      end

      it 'specified :known_only is used' do
        expect(rendered.include?('&amp;known_only=true')).to be(true)
      end

      it 'specified :managed_only is used' do
        expect(rendered.include?('&amp;managed_only=true')).to be(true)
      end

      it 'conditional user entered Org name is not visible by default' do
        expect(rendered.include?('<conditional>')).to be(false)
      end

      it 'specified :label is used' do
        expect(rendered.include?(@hash[:label])).to be(true)
      end

      it 'specified :namespace is used' do
        expect(rendered.include?("id=\"org_autocomplete_#{@hash[:namespace]}_name\"")).to be(true)
        expect(rendered.include?("name=\"org_autocomplete[#{@hash[:namespace]}_not_in_list]\"")).to be(false)
        expect(rendered.include?("id=\"org_autocomplete_#{@hash[:namespace]}_user_entered_name\"")).to be(false)
      end

      it 'unchangeable elements exist' do
        expect(rendered.include?('autocomplete-help')).to be(true)
        expect(rendered.include?('ui-front')).to be(true)
      end

      context 'when allowing a user entered Org name' do
        before do
          @hash[:known_only] = false
          @hash[:default_org] = build(:org)
          render partial: 'shared/org_autocomplete', locals: @hash
        end

        it 'specified :allow_custom_org_entry is used' do
          expect(rendered.include?('<conditional>')).to be(true)
        end

        it 'specified :namespace is used' do
          expect(rendered.include?("id=\"org_autocomplete_#{@hash[:namespace]}_name\"")).to be(true)
          expect(rendered.include?("name=\"org_autocomplete[#{@hash[:namespace]}_not_in_list]\"")).to be(true)
          expect(rendered.include?("id=\"org_autocomplete_#{@hash[:namespace]}_user_entered_name\"")).to be(true)
        end
      end
    end
  end

  it 'does not display the custom Org checkbox if :allow_custom_org_entry is false' do
    Rails.configuration.x.application.restrict_orgs = true
    render partial: 'shared/org_autocomplete'
    expect(rendered.include?('<conditional>')).to be(false)
    expect(rendered.include?('name="org_autocomplete[not_in_list]"')).to be(false)
    expect(rendered.include?('id="org_autocomplete_user_entered_name"')).to be(false)
  end
end
