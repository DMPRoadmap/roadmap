# frozen_string_literal: true

module SuperAdmin
  # Controller for creating and deleting RegistryValues
  class RegistryValuesController < ApplicationController
    def new
      @registry = Registry.find(params[:registry_id])
      authorize(@registry)
      @registry_value = RegistryValue.new
    end

    # rubocop:disable Metrics/AbcSize
    def create
      @registry = Registry.find(permitted_params[:registry_id])
      authorize(@registry)

      @registry_value = RegistryValue.new(permitted_params)
      if @registry_value.save
        flash.now[:notice] = success_message(@registry_value, _('created'))
      else
        flash.now[:alert] = failure_message(@registry_value, _('create'))
      end
      redirect_to super_admin_registry_path(@registry)
    end
    # rubocop:enable Metrics/AbcSize

    def edit
      @registry_value = RegistryValue.find(params[:id])
      @registry = @registry_value.registry
      authorize(@registry)
    end

    # rubocop:disable Metrics/AbcSize
    def update
      @registry_value = RegistryValue.find(params[:id])
      @registry = @registry_value.registry
      authorize(@registry)
      if @registry_value.update_attributes(permitted_params)
        @registry_value.update(data: JSON.parse(permitted_params[:data]))
        flash.now[:notice] = success_message(@registry_value, _('updated'))
      else
        flash.now[:alert] = failure_message(@registry_value, _('update'))
      end
      redirect_to super_admin_registry_path(@registry)
    end
    # rubocop:enable Metrics/AbcSize

    def destroy
      @registry_value = RegistryValue.find(params[:id])
      @registry = @registry_value.registry
      authorize(@registry)
      if @registry_value.destroy
        msg = success_message(@registry_value, _('deleted'))
        redirect_to super_admin_registry_path(@registry), notice: msg
      else
        flash.now[:alert] = failure_message(@registry_value, _('delete'))
        render :edit
      end
    end

    # Private instance methods
    private

    def permitted_params
      params.require(:registry_value).permit(:id, :data, :registry_id)
    end
  end
end
