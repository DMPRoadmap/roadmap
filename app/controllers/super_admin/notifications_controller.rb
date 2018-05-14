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
      begin
        n = Notification.new(notification_params)
        n.notification_type = 'global'
        n.save!
        flash[:notice] = _('Notification created successfully')
      rescue ActionController::ParameterMissing
        flash[:alert] = _('Unable to save since notification parameter is missing')
      rescue ActiveRecord::RecordInvalid => e
        flash[:alert] = e.message
      end
      redirect_to action: :index
    end

    # PATCH/PUT /notifications/1
    # PATCH/PUT /notifications/1.json
    def update
      authorize(Notification)
      begin
        @notification.update!(notification_params)
        flash[:notice] = _('Notification updated successfully')
      rescue ActionController::ParameterMissing
        flash[:alert] = _('Unable to save since notification parameter is missing')
      rescue ActiveRecord::RecordInvalid => e
        flash[:alert] = e.message
      end
      redirect_to action: :index
    end

    # DELETE /notifications/1
    # DELETE /notifications/1.json
    def destroy
      authorize(Notification)
      begin
        @notification.destroy
        flash[:notice] = _('Successfully destroyed your notification')
      rescue ActiveRecord::RecordNotDestroyed
        flash[:alert] = _('The theme with id %{id} could not be destroyed') % { id: params[:id] }
      end
      redirect_to action: :index
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
      flash[:alert] = _('There is no notification associated with id  %{id}') % { id: params[:id] }
      redirect_to action: :index
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_notifications
      @notifications = Notification.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(:title, :level, :body, :dismissable, :starts_at, :expires_at)
    end
  end
end
