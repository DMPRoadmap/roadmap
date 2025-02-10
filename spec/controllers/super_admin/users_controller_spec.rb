# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuperAdmin::UsersController, type: :controller do
  let(:super_admin) { create(:user, :super_admin) }
  let(:user) { create(:user, confirmed_at: nil) }

  before do
    sign_in super_admin
  end

  describe 'PUT #update' do
    context 'when confirming an unconfirmed user' do
      it 'sets confirmed_at to the current time' do
        put :update, params: { id: user.id, user: { confirmed_at: '1' } }
        user.reload
        expect(user.confirmed_at).to be_a(Time)
      end
    end

    context 'when unconfirming a confirmed user' do
      before do
        user.update(confirmed_at: Time.current)
      end

      it 'sets confirmed_at to nil' do
        put :update, params: { id: user.id, user: { confirmed_at: '0' } }
        user.reload
        expect(user.confirmed_at).to be_nil
      end
    end

    context 'when update will not affect confirmation status' do
      it 'does not update confirmed_at value for an already confirmed user' do
        # (usec: 0) removes mircoseconds to better enable comparison
        user.update(confirmed_at: Time.current.change(usec: 0))
        original_confirmed_at = user.confirmed_at
        patch :update, params: { id: user.id, user: { firstname: 'NewName', confirmed_at: '1' } }
        user.reload
        expect(user.confirmed_at).to eq(original_confirmed_at)
      end
    end
  end
end
