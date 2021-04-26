# frozen_string_literal: true

module SuperAdmin

  class NotificationsController < ApplicationController

    before_action :set_notification, only: %i[show edit update destroy acknowledge]
    before_action :set_notifications, only: :index

    helper PaginableHelper

    # GET /notifications
    # GET /notifications.json
    def index
      authorize(Notification)
      render(:index, locals: { notifications: @notifications.page(1) })
    end

    # GET /notifications/new
    def new
      authorize(Notification)
      @notification = Notification.new
    end

    # GET /notifications/1/edit
    def edit
      authorize(Notification)
    end

    # POST /notifications
    # POST /notifications.json
    def create
      authorize(Notification)
      @notification = Notification.new(notification_params)
      # Will eventually need to be removed if we introduce new notification types
      @notification.notification_type = "global"
      if @notification.save
        flash.now[:notice] = success_message(@notification, _("created"))
        render :edit
      else
        flash.now[:alert] = failure_message(@notification, _("create"))
        render :new
      end
    end

    # PATCH/PUT /notifications/1
    # PATCH/PUT /notifications/1.json
    def update
      authorize(Notification)
      if @notification.update(notification_params)
        flash.now[:notice] = success_message(@notification, _("updated"))
      else
        flash.now[:alert] = failure_message(@notification, _("update"))
      end
      render :edit
    end

    # edit active field displayed in the table
    def enable
      notification = Notification.find(params[:id])
      authorize(Notification)
      notification.enabled = (params[:enabled] == "1")

      # rubocop:disable Layout/LineLength
      if notification.save
        render json: {
          code: 1,
          msg: (notification.enabled ? _("Your notification is now active.") : _("Your notification is no longer active."))
        }
      else
        render status: :bad_request, json: {
          code: 0, msg: _("Unable to change the notification's active status")
        }
      end
      # rubocop:enable Layout/LineLength
    end

    # DELETE /notifications/1
    # DELETE /notifications/1.json
    def destroy
      authorize(Notification)
      if @notification.destroy
        msg = success_message(@notification, _("deleted"))
        redirect_to super_admin_notifications_path, notice: msg
      else
        flash.now[:alert] = failure_message(@notification, _("delete"))
        render :edit
      end
    end

    # GET /notifications/1/acknowledge
    def acknowledge
      @notification.acknowledge
      render nothing: true
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id] || params[:notification_id])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = _("There is no notification associated with id  %{id}") %
                      { id: params[:id] }
      redirect_to action: :index
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_notifications
      @notifications = Notification.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(:title, :level, :body, :dismissable, :enabled,
                                           :starts_at, :expires_at)
    end

  end

end
