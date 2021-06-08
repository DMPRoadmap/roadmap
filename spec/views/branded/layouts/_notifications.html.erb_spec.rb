# frozen_string_literal: true

require "rails_helper"

describe "layouts/_notifications.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  context "flash notifications" do
    it "renders correctly when there is no flash[:alert] or flash[:notice]" do
      render
      expect(rendered.include?("notification-area")).to eql(true)
      expect(rendered.include?("Notice:")).to eql(true)
      expect(rendered.include?("alert-info")).to eql(true)
      expect(rendered.include?("fa-check-circle")).to eql(true)
      expect(rendered.include?("<span></span>")).to eql(true)
      expect(rendered.include?("Error:")).to eql(false)
      expect(rendered.include?("alert-warning")).to eql(false)
      expect(rendered.include?("fa-times-circle")).to eql(false)
    end

    it "renders correctly when there is a flash[:notice]" do
      flash[:notice] = Faker::Lorem.sentence
      render
      expect(rendered.include?("notification-area")).to eql(true)
      expect(rendered.include?("Notice:")).to eql(true)
      expect(rendered.include?("alert-info")).to eql(true)
      expect(rendered.include?("fa-check-circle")).to eql(true)
      expect(rendered.include?("<span>#{flash[:notice]}</span>")).to eql(true)
      expect(rendered.include?("Error:")).to eql(false)
      expect(rendered.include?("alert-warning")).to eql(false)
      expect(rendered.include?("fa-times-circle")).to eql(false)
    end

    it "renders correctly when there is an flash[:alert]" do
      flash[:alert] = Faker::Lorem.sentence
      render
      expect(rendered.include?("notification-area")).to eql(true)
      expect(rendered.include?("Notice:")).to eql(false)
      expect(rendered.include?("alert-info")).to eql(false)
      expect(rendered.include?("fa-check-circle")).to eql(false)
      expect(rendered.include?("Error:")).to eql(true)
      expect(rendered.include?("alert-warning")).to eql(true)
      expect(rendered.include?("fa-times-circle")).to eql(true)
      expect(rendered.include?("<span>#{flash[:alert]}</span>")).to eql(true)
    end
  end

  context "global notifications" do
    it "displays nothing when user is not logged in and there are no messages" do
      render
      expect(rendered.include?("global-notification-area\">\n</div>")).to eql(true)
    end

    it "displays nothing when user is not logged in and no enabled messages" do
      create(:notification, dismissable: false, enabled: false)
      render
      expect(rendered.include?("global-notification-area\">\n</div>")).to eql(true)
    end

    it "displays the non-dismissable notification when user not logged in" do
      notification = create(:notification, dismissable: false, enabled: true)
      render
      expect(rendered.include?("global-notification-area")).to eql(true)
      expect(rendered.include?(notification.body)).to eql(true)
      expect(rendered.include?("notification_id=#{notification.id}")).to eql(false)
    end

    it "displays the non-dismissable notification when user is logged in" do
      notification = create(:notification, dismissable: false, enabled: true)
      sign_in create(:user)
      render
      expect(rendered.include?("global-notification-area")).to eql(true)
      expect(rendered.include?(notification.body)).to eql(true)
      expect(rendered.include?("notification_id=#{notification.id}")).to eql(false)
    end

    it "does not display the dismissable notification when user not logged in" do
      create(:notification, dismissable: true, enabled: true)
      render
      expect(rendered.include?("global-notification-area\">\n</div>")).to eql(true)
    end

    it "displays the dismissable notification when user is logged in" do
      notification = create(:notification, dismissable: true, enabled: true)
      sign_in create(:user)
      render
      expect(rendered.include?("global-notification-area")).to eql(true)
      expect(rendered.include?(notification.body)).to eql(true)
      expect(rendered.include?("notification_id=#{notification.id}")).to eql(true)
    end

    it "does not display the dismissable notification when user has already dismissed" do
      notification = create(:notification, dismissable: true, enabled: true)
      user = create(:user)
      notification.users << user
      notification.save
      sign_in user
      render
      expect(rendered.include?("global-notification-area\">\n</div>")).to eql(true)
    end
  end

end
