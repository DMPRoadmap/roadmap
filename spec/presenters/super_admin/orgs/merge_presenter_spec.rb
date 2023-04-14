# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuperAdmin::Orgs::MergePresenter do
  before(:each) do
    @to_org = create(:org, :organisation, is_other: false, managed: false,
                                          abbreviation: Faker::Lorem.unique.word,
                                          feedback_enabled: false, contact_email: nil,
                                          contact_name: nil, feedback_msg: nil,
                                          links: { org: [] })

    @tpt = create(:token_permission_type)
    @from_org = create(:org, :funder, templates: 1, plans: 0, managed: true,
                                      feedback_enabled: true, is_other: true,
                                      abbreviation: Faker::Lorem.unique.word,
                                      target_url: Faker::Internet.url,
                                      contact_name: Faker::Music::PearlJam.musician,
                                      contact_email: Faker::Internet.email,
                                      links: { org: { foo: 'bar' } },
                                      region: create(:region, name: Faker::Music::PearlJam.song),
                                      language: create(:language, abbreviation: 'merge-org'),
                                      token_permission_types: [@tpt])
    create(:annotation, org: @from_org)
    create(:department, org: @from_org)
    gg = @to_be_merged.guidance_groups.first if @from_org.guidance_groups.any?
    gg = create(:guidance_group, org: @from_org) unless gg.present?
    create(:guidance, guidance_group: gg)
    @id_no_scheme = create(:identifier, identifiable: @from_org, identifier_scheme: nil)
    @scheme = create(:identifier_scheme)
    @id_scheme = create(:identifier, identifiable: @from_org, identifier_scheme: @scheme)
    create(:plan, funder_id: @from_org.id)
    create(:plan, org: @from_org)
    create(:tracker, org: @from_org)
    @user = create(:user, org: @from_org)
    @from_org.reload
    @presenter = SuperAdmin::Orgs::MergePresenter.new(from_org: @from_org, to_org: @to_org)
  end

  describe ':initialize(from_org:, to_org:)' do
    it 'sets the cropped :to_org and :from_org' do
      expect(@presenter.to_org).to eql(@to_org)
      expect(@presenter.from_org).to eql(@from_org)
    end
    it 'sets the cropped :to_org_name and :from_org_name' do
      expect(@presenter.to_org_name.present? && @presenter.to_org_name.is_a?(String)).to eql(true)
      expect(@presenter.from_org_name.present? && @presenter.to_org_name.is_a?(String)).to eql(true)
    end
    it 'sets the :categories' do
      expect(@presenter.categories.any?).to eql(true)
      expect(@presenter.categories.first).to eql(:annotations)
      expect(@presenter.categories.last).to eql(:users)
    end
    it 'sets the :to_org_entries, :from_org_entries and mergeable_entries' do
      expect(@presenter.to_org_entries.is_a?(Hash)).to eql(true)
      expect(@presenter.from_org_entries.is_a?(Hash)).to eql(true)
      expect(@presenter.from_org_entries[:annotations].any?).to eql(true)
      expect(@presenter.mergeable_entries.is_a?(Hash)).to eql(true)
      expect(@presenter.mergeable_entries[:annotations].any?).to eql(true)
    end
    it 'sets the :from_org_attributes, :to_org_attributes and :mergeable_attributes' do
      expect(@presenter.to_org_attributes.is_a?(Hash)).to eql(true)
      expect(@presenter.from_org_attributes.is_a?(Hash)).to eql(true)
      expect(@presenter.from_org_attributes[:contact_email].present?).to eql(true)
      expect(@presenter.mergeable_attributes.is_a?(Hash)).to eql(true)
      expect(@presenter.mergeable_attributes[:target_url].present?).to eql(true)
    end
  end

  context 'private methods' do
    describe ':prepare_org(org:)' do
      it 'returns the expected categories for from_org' do
        results = @presenter.send(:prepare_org, org: @from_org)
        expect(results[:annotations].any?).to eql(true)
        expect(results[:departments].any?).to eql(true)
        expect(results[:funded_plans].any?).to eql(true)
        expect(results[:guidances].any?).to eql(true)
        expect(results[:identifiers].any?).to eql(true)
        expect(results[:plans].any?).to eql(true)
        expect(results[:templates].any?).to eql(true)
        expect(results[:token_permission_types].any?).to eql(true)
        expect(results[:tracker].any?).to eql(true)
        expect(results[:users].any?).to eql(true)
      end
      it 'returns the expected categories for to_org' do
        results = @presenter.send(:prepare_org, org: @to_org)
        expect(results[:annotations].any?).to eql(false)
        expect(results[:departments].any?).to eql(false)
        expect(results[:funded_plans].any?).to eql(false)
        expect(results[:guidances].any?).to eql(false)
        expect(results[:identifiers].any?).to eql(false)
        expect(results[:plans].any?).to eql(false)
        expect(results[:templates].any?).to eql(false)
        expect(results[:token_permission_types].any?).to eql(false)
        expect(results[:tracker].any?).to eql(false)
        expect(results[:users].any?).to eql(false)
      end
    end

    describe ':prepare_mergeables' do
      it 'returns the expected categories' do
        results = @presenter.send(:prepare_mergeables)
        expect(results[:annotations].any?).to eql(true)
        expect(results[:departments].any?).to eql(true)
        expect(results[:funded_plans].any?).to eql(true)
        expect(results[:guidances].any?).to eql(true)
        expect(results[:identifiers].any?).to eql(true)
        expect(results[:plans].any?).to eql(true)
        expect(results[:templates].any?).to eql(true)
        expect(results[:token_permission_types].any?).to eql(true)
        expect(results[:tracker].any?).to eql(true)
        expect(results[:users].any?).to eql(true)
      end
      it 'does not return :tracker if one is already defined on to_org' do
        create(:tracker, org: @to_org)
        @to_org.reload
        @presenter = SuperAdmin::Orgs::MergePresenter.new(from_org: @from_org, to_org: @to_org)
        results = @presenter.send(:prepare_mergeables)
        expect(results[:tracker]).to eql([])
      end
    end

    describe ':diff_from_and_to(category:)' do
      before(:each) do
        @entries = %i[annotations departments funded_plans guidances identifiers
                      plans templates token_permission_types tracker users]
      end
      it 'returns an empty array if category is not present' do
        expect(@presenter.send(:diff_from_and_to, category: nil)).to eql([])
      end
      it 'returns an empty array if category is not an org entry' do
        expect(@presenter.send(:diff_from_and_to, category: :foo)).to eql([])
      end
      it 'returns the from_org entries for :annotations' do
        results = @presenter.send(:diff_from_and_to, category: :annotations)
        expect(results).to eql(@from_org.annotations.to_a)
      end
      it 'returns the uniquie entries for :departments' do
        dup_department = build(:department)
        @from_org.departments << dup_department
        @to_org.departments << dup_department
        @presenter = SuperAdmin::Orgs::MergePresenter.new(from_org: @from_org, to_org: @to_org)
        results = @presenter.send(:diff_from_and_to, category: :departments)
        expect(results.include?(dup_department)).to eql(false)
        expect(results).to eql(@from_org.departments.reject { |dpt| dpt == dup_department })
      end
      it 'returns the from_org entries for :funded_plans' do
        results = @presenter.send(:diff_from_and_to, category: :funded_plans)
        expect(results).to eql(@from_org.funded_plans.to_a)
      end
      it 'returns the all entries for :guidances' do
        results = @presenter.send(:diff_from_and_to, category: :guidances)
        expect(results).to eql(@from_org.guidance_groups.map(&:guidances).flatten.to_a)
      end
      it 'returns the :identifiers that have no :identifier_scheme' do
        to_id = build(:identifier, identifier_scheme: nil)
        @to_org.identifiers << to_id
        @presenter = SuperAdmin::Orgs::MergePresenter.new(from_org: @from_org, to_org: @to_org)
        results = @presenter.send(:diff_from_and_to, category: :identifiers)
        expect(results.include?(@id_no_scheme)).to eql(true)
      end
      it 'returns the :identifiers that are not defined in to_org for the :identifier_scheme' do
        to_id = build(:identifier, identifier_scheme: build(:identifier_scheme))
        @to_org.identifiers << to_id
        @presenter = SuperAdmin::Orgs::MergePresenter.new(from_org: @from_org, to_org: @to_org)
        results = @presenter.send(:diff_from_and_to, category: :identifiers)
        expect(results.include?(@id_scheme)).to eql(true)
      end
      it 'does not return the :identifiers that are defined in to_org for the :identifier_scheme' do
        to_id = build(:identifier, identifier_scheme: @scheme)
        @to_org.identifiers << to_id
        @presenter = SuperAdmin::Orgs::MergePresenter.new(from_org: @from_org, to_org: @to_org)
        results = @presenter.send(:diff_from_and_to, category: :identifiers)
        expect(results.include?(@id_scheme)).to eql(false)
      end
      it 'returns the from_org entries for :plans' do
        results = @presenter.send(:diff_from_and_to, category: :plans)
        expect(results).to eql(Plan.where(org: @from_org).to_a)
      end
      it 'returns the from_org entries for :templates' do
        results = @presenter.send(:diff_from_and_to, category: :templates)
        expect(results).to eql(@from_org.templates.to_a)
      end
      it 'returns the :token_permission_types that are not defined on to_org' do
        results = @presenter.send(:diff_from_and_to, category: :token_permission_types)
        expect(results).to eql(@from_org.token_permission_types.to_a)
      end
      it 'does not return the :token_permission_types that are defined on to_org' do
        @to_org.token_permission_types << @tpt
        @presenter = SuperAdmin::Orgs::MergePresenter.new(from_org: @from_org, to_org: @to_org)
        results = @presenter.send(:diff_from_and_to, category: :token_permission_types)
        expect(results.include?(@tpt)).to eql(false)
      end
      it 'returns the from_org entries for :users not defined on to_org' do
        results = @presenter.send(:diff_from_and_to, category: :users)
        expect(results).to eql(@from_org.users.to_a)
      end
      it 'does not return the :users that are defined on to_org' do
        @to_org.users << @user
        @presenter = SuperAdmin::Orgs::MergePresenter.new(from_org: @from_org, to_org: @to_org)
        results = @presenter.send(:diff_from_and_to, category: :users)
        expect(results.include?(@user)).to eql(false)
      end
    end

    describe ':org_attributes(org:)' do
      before(:each) do
        @expected = %i[target_url managed links
                       contact_name contact_email
                       logo_uid logo_name
                       feedback_enabled feedback_msg]
        @results = @presenter.send(:org_attributes, org: @from_org)
      end
      it 'returns an empty hash if :org is not an Org' do
        expect(@presenter.send(:org_attributes, org: build(:user))).to eql({})
      end
      it 'includes the expected columns' do
        @expected.each { |column| expect(@results[column]).to eql(@from_org.send(column)) }
      end
      it 'does not include any other columns than the ones we expect' do
        @results.each_key { |key| expect(@expected.include?(key)).to eql(true) }
      end
    end

    describe ':mergeable_columns' do
      before(:each) do
        @expected = %i[target_url managed links
                       contact_name contact_email
                       feedback_enabled feedback_msg]
        @results = @presenter.send(:mergeable_columns)
      end
      it 'includes the expected columns' do
        @expected.each { |column| expect(@results[column].present?).to eql(true) }
      end
      it 'does not include any other columns than the ones we expect' do
        @results.each_key { |key| expect(@expected.include?(key)).to eql(true) }
      end
    end
    describe ':mergeable_column?(column:)' do
      it 'returns false if the :to_org is :managed but the :from_org is not' do
        @presenter.to_org.stubs(:managed?).returns(true)
        @presenter.from_org.stubs(:managed?).returns(false)
        expect(@presenter.send(:mergeable_column?, column: :managed)).to eql(false)
      end
      it 'returns false if the :to_org has :feedback_enabled but the :from_org does not' do
        @presenter.to_org.stubs(:feedback_enabled?).returns(true)
        @presenter.from_org.stubs(:feedback_enabled?).returns(false)
        expect(@presenter.send(:mergeable_column?, column: :feedback_enabled)).to eql(false)
      end
      it 'returns false if the :from_org links is an empty json' do
        @presenter.from_org.stubs(:links).returns({})
        expect(@presenter.send(:mergeable_column?, column: :links)).to eql(false)
      end
      it 'returns false if the :to_org already has a value' do
        @presenter.to_org.stubs(:contact_email).returns(Faker::Internet.email)
        expect(@presenter.send(:mergeable_column?, column: :contact_email)).to eql(false)
      end
      it 'returns false if the :from_org does not have a value' do
        @presenter.from_org.stubs(:contact_email).returns(nil)
        expect(@presenter.send(:mergeable_column?, column: :contact_email)).to eql(false)
      end
      it 'returns true for :target_url' do
        expect(@presenter.send(:mergeable_column?, column: :target_url)).to eql(true)
      end
      it 'returns true for :managed' do
        expect(@presenter.send(:mergeable_column?, column: :managed)).to eql(true)
      end
      it 'returns true for :links' do
        expect(@presenter.send(:mergeable_column?, column: :links)).to eql(true)
      end
      it 'returns true for :contact_name' do
        expect(@presenter.send(:mergeable_column?, column: :contact_name)).to eql(true)
      end
      it 'returns true for :contact_email' do
        expect(@presenter.send(:mergeable_column?, column: :contact_email)).to eql(true)
      end
      it 'returns true for :feedback_enabled' do
        expect(@presenter.send(:mergeable_column?, column: :feedback_enabled)).to eql(true)
      end
      it 'returns true for :feedback_msg' do
        expect(@presenter.send(:mergeable_column?, column: :feedback_msg)).to eql(true)
      end
    end
  end
end
