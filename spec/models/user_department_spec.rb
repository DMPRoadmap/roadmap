# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, 'department membership', type: :model do
  let(:org) { create(:org) }
  let(:department) { create(:department, org_id: org.id) }
  let(:user) { create(:user, org: org) }

  it 'allows users without a department' do
    expect(user).to be_valid
  end

  it 'allows a department from the user organization' do
    expect(user.update(department: department)).to be(true)
    expect(user.reload.department).to eq(department)
  end

  it 'rejects a department from another organization' do
    foreign_department = create(:department, org_id: create(:org).id)

    expect(user.update(department: foreign_department)).to be(false)
    expect(user.errors[:department]).to be_present
    expect(user.reload.department).to be_nil
  end

  it 'rejects nonexistent department IDs without persisting the assignment' do
    expect(user.update(department_id: Department.maximum(:id).to_i + 1)).to be(false)
    expect(user.errors[:department]).to be_present
    expect(user.reload.department).to be_nil
  end

  it 'allows clearing a department' do
    user.update!(department: department)

    expect(user.update(department: nil)).to be(true)
    expect(user.reload.department).to be_nil
  end

  it 'persists removal of the old department when changing organization' do
    user.update!(department: department)
    user.update!(org: create(:org))

    expect(user.reload.department).to be_nil
  end

  it 'allows assigning a department in the new organization in the same update' do
    user.update!(department: department)
    new_org = create(:org)
    new_department = create(:department, org_id: new_org.id)
    user.update!(org: new_org, department: new_department)

    expect(user.reload.department).to eq(new_department)
  end

  it 'allows creating a user with a department from their organization' do
    new_user = create(:user, org: org, department: department)

    expect(new_user.reload.department).to eq(department)
  end

  it 'rejects a new department outside the new organization when both change' do
    user.update!(department: department)
    foreign_department = create(:department, org_id: create(:org).id)

    expect(user.update(org: create(:org), department: foreign_department)).to be(false)
    expect(user.reload.org).to eq(org)
    expect(user.department).to eq(department)
  end

  it 'clears the old department when an organization change skips validation' do
    user.update!(department: department)
    user.org = create(:org)
    user.save!(validate: false)

    expect(user.reload.department).to be_nil
  end

  it 'clears the old department when update_attribute changes organization' do
    user.update!(department: department)
    user.update_attribute(:org_id, create(:org).id)

    expect(user.reload.department).to be_nil
  end

  context 'with a legacy department from another organization' do
    before do
      foreign_department = create(:department, org_id: create(:org).id)
      user.update_column(:department_id, foreign_department.id)
      user.reload
    end

    it 'allows unrelated profile changes without changing department membership' do
      expect(user.update(firstname: 'Updated')).to be(true)
      expect(user.reload.firstname).to eq('Updated')
    end

    it 'allows password resets' do
      expect(user.reset_password('New-password-601!', 'New-password-601!')).to be(true)
      expect(user.reload.valid_password?('New-password-601!')).to be(true)
    end

    it 'allows correcting the legacy department assignment' do
      expect(user.update(department: department)).to be(true)
      expect(user.reload.department).to eq(department)
    end

    it 'still rejects assigning a different foreign department' do
      foreign_department = create(:department, org_id: create(:org).id)

      expect(user.update(department: foreign_department)).to be(false)
      expect(user.errors[:department]).to be_present
    end
  end

  it 'rejects a mismatched department when creating a user' do
    new_user = build(:user, org: create(:org), department: department)

    expect(new_user).not_to be_valid
    expect(new_user.errors[:department]).to be_present
  end
end
