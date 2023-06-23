# frozen_string_literal: true

require 'json'
module SuperAdmin
  # Controller for creating and deleting Registries
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

    # rubocop:disable Metrics/AbcSize
    def create
      authorize(Registry)
      attrs = permitted_params
      @registry = Registry.new(attrs.except(:values))
      if @registry.save
        flash.now[:notice] = success_message(@registry, _('created'))
        load_values(attrs[:values], @registry)
        render :edit
      else
        flash.now[:alert] = failure_message(@registry, _('create'))
        render :new
      end
    end
    # rubocop:enable Metrics/AbcSize

    def edit
      authorize(Registry)
      @registry = Registry.find(params[:id])
    end

    # rubocop:disable Metrics/AbcSize
    def update
      authorize(Registry)
      attrs = permitted_params
      @registry = Registry.find(params[:id])
      if @registry.update(attrs.except(:values))
        flash.now[:notice] = success_message(@registry, _('updated'))
      else
        flash.now[:alert] = failure_message(@registry, _('update'))
      end
      load_values(attrs[:values], @registry)

      render :edit
    end
    # rubocop:enable Metrics/AbcSize

    def destroy
      authorize(Registry)
      @registry = Registry.find(params[:id])
      if @registry.destroy
        msg = success_message(@registry, _('deleted'))
        redirect_to super_admin_registries_path, notice: msg
      else
        flash.now[:alert] = failure_message(@registry, _('delete'))
        redner :edit
      end
    end

    def sort_values
      @registry = Registry.find(params[:id])
      authorize @registry
      params[:updated_order].each_with_index do |id, index|
        RegistryValue.find(id).update!(order: index + 1)
      end
      head :ok
    end

    def download
      registry = Registry.find(params[:registry_id])
      authorize registry
      values = registry.registry_values.map(&:data)
      data = { registry.name => values }
      send_data(JSON.pretty_generate(data), filename: "#{registry.name}.json")
    end

    def upload
      registry = Registry.find(params[:registry_id])
      authorize registry
    end

    # Private instance methods
    private

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def load_values(values_file, registry)
      return if values_file.nil?

      if values_file.respond_to?(:read)
        values_data = values_file.read
      elsif values_file.respond_to?(:path)
        values_data = File.read(values_file.path)
      else
        logger.error "Bad values_file: #{values_file.class.name}: #{values_file.inspect}"
      end
      begin
        json_values = JSON.parse(values_data)
        if json_values.key?(registry.name)
          registry.registry_values.delete_all
          registry_values = []
          json_values[registry.name].each_with_index do |reg_val, idx|
            registry_values << RegistryValue.new(data: reg_val, registry:, order: idx)
          end
          RegistryValue.import registry_values
        else
          flash.now[:alert] = 'Wrong values file format'
        end
      rescue JSON::ParserError
        flash.now[:alert] = 'File should contain JSON'
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def permitted_params
      params.require(:registry).permit(:name, :description, :uri, :version, :values)
    end
  end
end
