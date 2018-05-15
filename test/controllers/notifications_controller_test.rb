require 'test_helper'
module SuperAdmin
  class NotificationsControllerTest < ActionController::TestCase
    fixtures :notifications, :users, :perms
    include Devise::Test::ControllerHelpers

    setup do
      sign_in users(:super_admin)
      @notification = notifications(:notification_1)
      @notification_attributes = {
        notification_type: @notification.notification_type,
        title: @notification.title,
        level: @notification.level,
        body: @notification.body,
        dismissable: @notification.dismissable,
        starts_at: @notification.starts_at,
        expires_at: @notification.expires_at
      }
    end

    test 'should get index' do
      get :index
      assert_response :success
      assert_not_nil assigns(:notifications)
    end

    test 'should get new' do
      get :new
      assert_response :success
    end

    test 'should create notification' do
      assert_difference('Notification.count') do
        post :create, notification: @notification_attributes
      end

      assert_redirected_to super_admin_notifications_url
    end

    test 'should get edit' do
      get :edit, id: @notification
      assert_response :success
      assert_not_nil assigns(:notification)
    end

    test 'should update notification' do
      patch :update, id: @notification, notification: @notification_attributes
      assert_redirected_to super_admin_notifications_url
    end

    test 'should destroy notification' do
      assert_difference('Notification.count', -1) do
        delete :destroy, id: @notification
      end

      assert_redirected_to super_admin_notifications_url
    end

    test 'unauthorized redirections' do
      sign_in users(:unprivileged_user)

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
