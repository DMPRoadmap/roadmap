# frozen_string_literal: true

require "rails_helper"

describe "layouts/_app_menu.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "renders nothing if user is not logged in" do
    render
    expect(rendered).to eql("")
  end

  it "renders our version of the page" do
    sign_in create(:user)
    render
    expect(response).to render_template(partial: "layouts/_app_menu_links")
  end

end
