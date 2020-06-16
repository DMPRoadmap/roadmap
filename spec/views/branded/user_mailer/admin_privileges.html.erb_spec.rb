# frozen_string_literal: true

require "rails_helper"

describe "user_mailer/admin_privileges.html.erb" do
  before(:each) do
    @url = "https://github.com/CDLUC3/dmptool/wiki/Help-for-Administrators"
    controller.prepend_view_path "app/views/branded"
  end

  it "renders the email for a user who received Admin privileges" do
    user = create(:user, :org_admin)
    assign :user, user
    render
    expect(rendered.include?("Hello #{user.name(false)}")).to eql(true)
    expect(rendered.include?("granted")).to eql(true)
    expect(rendered.include?(@url)).to eql(true)
  end

  it "renders the email for the user whose Admin privileges have been revoked" do
    user = create(:user)
    assign :user, user
    render
    expect(rendered.include?("Hello #{user.name(false)}")).to eql(true)
    expect(rendered.include?("revoked")).to eql(true)
    expect(rendered.include?(@url)).to eql(true)
  end

end
