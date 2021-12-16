# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::Shibbolethable, type: :request do
  include DmptoolHelper

  before(:each) do
    @admin = create(:user, :org_admin, org: create(:org))
    @controller = ::UsersController.new
  end

  xit 'Controllers includes our customizations' do
    expect(@controller.respond_to?(:foo)).to eql(true)
  end
end
