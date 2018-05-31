require 'test_helper'
module SuperAdmin
  class NotificationsControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup do
      @super_admin = User.find_by(email: 'super_admin@example.com')
      scaffold_org_admin(Org.last)

      @notification_attributes = {
        notification_type: Notification.notification_types[:global], 
        title: 'notification_1', 
        level: Notification.levels[:info],
        body: 'notification 1', 
        dismissable: true, 
        starts_at: Date.today, 
        expires_at: Date.tomorrow
      }
      @notification = Notification.create!(@notification_attributes)
    end

    test 'should get index' do
      sign_in @super_admin
      get :index
      assert_response :success
      assert_not_nil assigns(:notifications)
    end

    test 'should get new' do
      sign_in @super_admin
      get :new
      assert_response :success
    end

    test 'should create notification' do
      sign_in @super_admin
      assert_difference('Notification.count') do
        @notification_attributes[:level] = :info #controller is expecting the symbol instead of the numerical value
        post :create, notification: @notification_attributes
      end
      assert_redirected_to super_admin_notifications_url
    end

    test 'should get edit' do
      sign_in @super_admin
      get :edit, id: @notification
      assert_response :success
      assert_not_nil assigns(:notification)
    end

    test 'should update notification' do
      sign_in @super_admin
      @notification_attributes[:title] = 'notification_2'
      @notification_attributes[:level] = :info #controller is expecting the symbol instead of the numerical value
      patch :update, id: @notification, notification: @notification_attributes
      assert_redirected_to super_admin_notifications_url
    end

    test 'should destroy notification' do
      sign_in @super_admin
      assert_difference('Notification.count', -1) do
        delete :destroy, id: @notification
      end
      assert_redirected_to super_admin_notifications_url
    end

    test 'unauthorized redirections' do
      sign_in @user
      get :index
      assert_redirected_to(plans_url)
      get :new
      assert_redirected_to(plans_url)
      post :create, notification: @notification_attributes
      assert_redirected_to(plans_url)
      get :edit, id: @notification
      assert_redirected_to(plans_url)
      patch :update, id: @notification, notification: @notification_attributes
      assert_redirected_to(plans_url)
      delete :destroy, id: @notification
      assert_redirected_to(plans_url)
    end
  end
end
