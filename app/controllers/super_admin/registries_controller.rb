# frozen_string_literal: true

module SuperAdmin
  class RegistriesController < ApplicationController

    # GET /madmp_schemas
    def index
      authorize(Registry)
      render(:index, locals: { registries: Registry.all.page(1) })
    end

    def show
      authorize(Registry)
      @registry = Registry.includes(:registry_values).find(params[:id])
    end

    def new
      authorize(Registry)
      @registry = Registry.new
    end

    def create
      authorize(Registry)
      @registry = Registry.new(permitted_params)
      if @registry.save
        flash.now[:notice] = success_message(@registry, _("created"))
        render :edit
      else
        flash.now[:alert] = failure_message(@registry, _("create"))
        render :new
      end
    end
  
    def edit
      authorize(Registry)
      @registry = Registry.find(params[:id])
    end


    def update
      authorize(Registry)
      @registry = Registry.find(params[:id])
      if @registry.update_attributes(permitted_params)
        flash.now[:notice] = success_message(@registry, _("updated"))
      else
        flash.now[:alert] = failure_message(@registry, _("update"))
      end
      render :edit
    end

    def destroy
      authorize(Registry)
      @registry = Registry.find(params[:id])
      if @registry.destroy
        msg = success_message(@registry, _("deleted"))
        redirect_to super_admin_registries_path, notice: msg
      else
        flash.now[:alert] = failure_message(@registry, _("delete"))
        redner :edit
      end
    end


    # Private instance methods
    private

    def permitted_params
      params.require(:registry).permit(:name, :description, :uri, :version)
    end

  end
end
