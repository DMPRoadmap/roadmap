# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Super-admin combined user updates', type: :request do
  let(:org) { create(:org) }
  let(:department) { create(:department, org: org) }
  let(:target) { create(:user, org: org, department: department) }
  let(:actor) { create(:user, :super_admin) }
  let(:new_org) { create(:org) }
  let!(:new_department) { create(:department, org: new_org) }
  let(:selection) { { id: new_org.id, name: new_org.name }.to_json }

  before do
    target
    sign_in actor
  end

  def department_options
    Nokogiri::HTML(response.body).css('select[name="user[department_id]"] option').map { |option| option['value'] }
  end

  it 'saves the organization and its selected department together' do
    put "/super_admin/users/#{target.id}",
        params: { user: { org_id: selection, department_id: new_department.id } }

    expect(response).to have_http_status(:ok)
    expect(target.reload.org).to eq(new_org)
    expect(target.department).to eq(new_department)
    expect(department_options).to include(new_department.id.to_s)
    expect(department_options).not_to include(department.id.to_s)
  end

  it 'retains persisted attributes and renders the selected organization after a failed profile update' do
    original_email = target.email
    original_firstname = target.firstname
    put "/super_admin/users/#{target.id}",
        params: { user: { org_id: selection, department_id: new_department.id,
                          firstname: '', email: 'profile-update@example.test' } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(target.reload.org).to eq(org)
    expect(target.department).to eq(department)
    expect(target.email).to eq(original_email)
    expect(target.firstname).to eq(original_firstname)
    expect(department_options).to include(new_department.id.to_s)
    expect(department_options).not_to include(department.id.to_s)
    document = Nokogiri::HTML(response.body)
    expect(document.at_css('input[name="user[org_name]"]')['value']).to eq(new_org.name)
    selected_option = document.at_css('select[name="user[department_id]"] option[selected]')
    expect(selected_option['value']).to eq(new_department.id.to_s)
  end

  it 'rejects a department outside the selected organization without partially saving the user' do
    foreign_department = create(:department, org: create(:org))
    put "/super_admin/users/#{target.id}",
        params: { user: { org_id: selection, department_id: foreign_department.id } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('must belong to the same organization as the user')
    expect(target.reload.org).to eq(org)
    expect(target.department).to eq(department)
    expect(department_options).to include(new_department.id.to_s)
    expect(department_options).not_to include(department.id.to_s, foreign_department.id.to_s)
  end

  it 'clears the previous department when changing organization without a replacement' do
    put "/super_admin/users/#{target.id}", params: { user: { org_id: selection } }

    expect(response).to have_http_status(:ok)
    expect(target.reload.org).to eq(new_org)
    expect(target.department).to be_nil
    expect(department_options).to include(new_department.id.to_s)
    expect(department_options).not_to include(department.id.to_s)
  end

  it 'allows an explicit blank department with the new organization' do
    put "/super_admin/users/#{target.id}", params: { user: { org_id: selection, department_id: '' } }

    expect(response).to have_http_status(:ok)
    expect(target.reload.org).to eq(new_org)
    expect(target.department).to be_nil
  end

  it 'preserves the department when the selected organization is unchanged' do
    put "/super_admin/users/#{target.id}",
        params: { user: { org_id: { id: org.id, name: org.name }.to_json, firstname: 'Updated' } }

    expect(response).to have_http_status(:ok)
    expect(target.reload.org).to eq(org)
    expect(target.department).to eq(department)
    expect(target.firstname).to eq('Updated')
  end

  it 'creates a selected organization and its identifier without the controller fallback' do
    Rails.configuration.x.application.stubs(:restrict_orgs).returns(false)
    scheme = create(:identifier_scheme, name: 'ror', for_orgs: true, identifier_prefix: 'https://ror.org/')
    ror = 'https://ror.org/012345678'
    name = 'Synthetic new profile institution'

    expect do
      put "/super_admin/users/#{target.id}", params: { user: { org_id: { name: name, ror: ror }.to_json } }
    end.to change(Org, :count).by(1)

    expect(response).to have_http_status(:ok)
    created_org = Org.find_by!(name: name)
    expect(target.reload.org).to eq(created_org)
    expect(target.department).to be_nil
    expect(created_org.identifiers.where(identifier_scheme: scheme, value: ror).count).to eq(1)
  end

  it 'uses an existing organization when organization creation is restricted' do
    Rails.configuration.x.application.stubs(:restrict_orgs).returns(true)
    put "/super_admin/users/#{target.id}",
        params: { user: { org_id: selection, department_id: new_department.id } }

    expect(response).to have_http_status(:ok)
    expect(target.reload.org).to eq(new_org)
    expect(target.department).to eq(new_department)
  end

  it 'does not create an unknown organization when organization creation is restricted' do
    Rails.configuration.x.application.stubs(:restrict_orgs).returns(true)

    expect do
      put "/super_admin/users/#{target.id}",
          params: { user: { org_id: { name: 'Unlisted restricted institution' }.to_json, firstname: 'Updated' } }
    end.not_to change(Org, :count)

    expect(response).to have_http_status(:ok)
    expect(target.reload.org).to eq(org)
    expect(target.department).to eq(department)
    expect(target.firstname).to eq('Updated')
  end

  it 'preserves department membership when no organization is submitted' do
    put "/super_admin/users/#{target.id}", params: { user: { firstname: 'Updated' } }

    expect(response).to have_http_status(:ok)
    expect(target.reload.org).to eq(org)
    expect(target.department).to eq(department)
    expect(target.firstname).to eq('Updated')
  end
end
