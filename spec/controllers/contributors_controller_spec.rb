# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContributorsController, type: :controller do
  before(:each) do
    @scheme = create(:identifier_scheme, name: 'orcid')
    @org = create(:org, managed: true)
    @plan = create(:plan, :creator, org: @org)
    @user = @plan.owner
    @contributor = create(:contributor, plan: @plan, org: @org)

    @params_hash = {
      contributor: {
        name: Faker::TvShows::Simpsons.character,
        email: Faker::Internet.email,
        phone: Faker::Number.number,
        org_id: {
          id: @org.id,
          name: @org.name,
          ror: Faker::Lorem.word
        }.to_json,
        identifiers_attributes: { '0': {
          identifier_scheme_id: @scheme.id,
          value: SecureRandom.uuid
        } }
      }
    }
    @roles = Contributor.new.all_roles
    @params_hash[:contributor][@roles.sample.to_sym] = '1'
    @controller = described_class.new
  end

  context 'actions' do
    before(:each) do
      sign_in(@user)
    end

    it 'GET plans/:plan_id/contributors (:index)' do
      get :index, params: { plan_id: @plan.id }
      expect(response).to render_template(:index)
      expect(assigns(:plan)).to eql(@plan)
      expect(assigns(:contributors).length).to eql(1)
      expect(assigns(:contributors).first).to eql(@contributor)
    end

    it 'GET plans/:plan_id/contributors/new (:new)' do
      get :new, params: { plan_id: @plan.id }
      expect(response).to render_template(:new)
      expect(assigns(:plan)).to eql(@plan)
      expect(assigns(:contributor).new_record?).to eql(true)
      expect(assigns(:contributor).plan).to eql(@plan)
    end

    it 'GET plans/:plan_id/contributors/:id/edit (:edit)' do
      get :edit, params: { plan_id: @plan.id, id: @contributor.id }
      expect(response).to render_template(:edit)
      expect(assigns(:plan)).to eql(@plan)
      expect(assigns(:contributor)).to eql(@contributor)
    end

    it 'POST plans/:plan_id/contributors (:create)' do
      post :create, params: @params_hash.merge({ plan_id: @plan.id })
      expect(response).to redirect_to(plan_contributors_url(@plan))
      contrib = Contributor.last
      params = @params_hash[:contributor]

      # Verify that the plan was attached
      expect(contrib.plan).to eql(@plan)

      # Verify that the contributor fields were all saved
      expect(contrib.name).to eql(params[:name])
      expect(contrib.email).to eql(params[:email])
      expect(contrib.phone).to eql(params[:phone].to_s)

      # Verify that the corrrect roles were assigned
      contrib.all_roles.each do |role|
        expect(contrib.send(:"#{role}?")).to eql(params[:"#{role}"] == '1')
      end

      # Verify that the Org was attached
      expect(contrib.org).to eql(@org)

      # Verify that the ORCID was saved
      expected = params[:identifiers_attributes][:'0'][:value]
      expect(contrib.identifiers.first.identifier_scheme).to eql(@scheme)
      expect(contrib.identifiers.first.value.ends_with?(expected)).to eql(true)
    end

    it 'PUT plans/:plan_id/contributors/:id (:update)' do
      put :update, params: @params_hash.merge({ plan_id: @plan.id, id: @contributor.id })
      @contributor.reload
      params = @params_hash[:contributor]

      expect(response).to redirect_to(edit_plan_contributor_url(@plan, @contributor))

      # Verify that the contributor fields were all saved
      expect(@contributor.name).to eql(params[:name])
      expect(@contributor.email).to eql(params[:email])
      expect(@contributor.phone).to eql(params[:phone].to_s)

      # Verify that the corrrect roles were assigned
      @contributor.all_roles.each do |role|
        expect(@contributor.send(:"#{role}?")).to eql(params[:"#{role}"] == '1')
      end

      # Verify that the Org was attached
      expect(@contributor.org).to eql(@org)

      # Verify that the ORCID was saved
      expected = params[:identifiers_attributes][:'0'][:value]
      expect(@contributor.identifiers.first.identifier_scheme).to eql(@scheme)
      expect(@contributor.identifiers.first.value.ends_with?(expected)).to eql(true)
    end

    it 'DELETE plans/:plan_id/contributors/:id (:destroy)' do
      id = @contributor.id
      delete :destroy, params: @params_hash.merge({ plan_id: @plan.id, id: @contributor.id })
      expect(Contributor.where(id: id).any?).to eql(false)
    end
  end

  context 'private methods(hash:)' do
    describe '#translate_roles' do
      it 'converts integer to boolean' do
        roles = @controller.send(:translate_roles, hash: @params_hash[:contributor])
        expect([true, false].include?(roles[@roles.first])).to eql(true)
      end
      it 'leaves non-role integers alone' do
        @params_hash[:contributor][:non_role] = '1'
        roles = @controller.send(:translate_roles, hash: @params_hash[:contributor])
        expect(roles[:non_role]).to eql('1')
      end
    end

    describe '#process_org(hash:)' do
      it 'returns the hash as is if no :org_id is present' do
        @params_hash[:contributor].delete(:org_id)
        hash = @controller.send(:process_org, hash: @params_hash[:contributor])
        expect(hash).to eql(@params_hash[:contributor])
      end
      it 'with no restrict_orgs defined, returns the hash if the org could not be converted' do
        Rails.configuration.x.application.restrict_orgs = nil
        @controller.stubs(:org_from_params).returns(nil)
        hash = @controller.send(:process_org, hash: @params_hash[:contributor])
        expect(hash).to eql(@params_hash[:contributor])
      end
      it 'with restrict_orgs=false, returns the hash if the org could not be converted' do
        Rails.configuration.x.application.restrict_orgs = false
        @controller.stubs(:org_from_params).returns(nil)
        hash = @controller.send(:process_org, hash: @params_hash[:contributor])
        expect(hash).to eql(@params_hash[:contributor])
      end
      it 'with restrict_orgs=true, returns hash if the org could not be converted' do
        Rails.configuration.x.application.restrict_orgs = true
        @controller.stubs(:org_from_params).returns(nil)
        hash = @controller.send(:process_org, hash: @params_hash[:contributor])
        expect(hash).to eql(@params_hash[:contributor])
      end
      it 'sets the org_id to the idea of the org' do
        new_org = create(:org)
        @controller.stubs(:org_from_params).returns(new_org)
        hash = @controller.send(:process_org, hash: @params_hash[:contributor])
        expect(hash[:org_id]).to eql(new_org.id)
      end
    end

    context 'callbacks' do
      describe '#fetch_plan' do
        it 'assigns the plan instance variable' do
          get :index, params: { plan_id: @plan.id }
          expect(assigns(:plan)).to eql(@plan)
        end
        it 'redirects to :root if no plan found' do
          get :index, params: { plan_id: 99_999 }
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(root_url)
        end
      end

      describe '#fetch_contributor' do
        it 'is not triggered on POST :create' do
          described_class.any_instance.expects(:fetch_contributor).at_most(0)
          post :create, params: @params_hash.merge({ plan_id: @plan.id })
        end
        it 'is not triggered on GET :index' do
          described_class.any_instance.expects(:fetch_contributor).at_most(0)
          get :index, params: { plan_id: @plan.id }
        end
        it 'is not triggered on GET :new' do
          described_class.any_instance.expects(:fetch_contributor).at_most(0)
          get :new, params: { plan_id: @plan.id }
        end
        it 'assigns the contributor instance variable' do
          get :edit, params: { plan_id: @plan.id, id: @contributor.id }
          expect(assigns(:contributor)).to eql(@contributor)
        end
        it 'redirects to :index if no contributor found' do
          get :edit, params: { plan_id: @plan.id, id: 99_999 }
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(plan_contributors_url(@plan))
        end
        it 'redirects to :index if contributor does not belong to the plan' do
          contrib = create(:contributor, plan: create(:plan))
          get :edit, params: { plan_id: @plan.id, id: contrib.id }
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to(plan_contributors_url(@plan))
        end
      end
    end
  end
end
