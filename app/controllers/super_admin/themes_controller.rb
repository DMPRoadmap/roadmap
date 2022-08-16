# frozen_string_literal: true

module SuperAdmin
  # Controller for managing Themes
  class ThemesController < ApplicationController
    helper PaginableHelper
    def index
      authorize(Theme)
      render(:index, locals: { themes: Theme.all.page(1) })
    end

    def new
      authorize(Theme)
      @theme = Theme.new
    end

    def create
      authorize(Theme)
      @theme = Theme.new(permitted_params)
      if @theme.save
        flash.now[:notice] = success_message(@theme, _('created'))
        render :edit
      else
        flash.now[:alert] = failure_message(@theme, _('create'))
        render :new
      end
    end

    def edit
      authorize(Theme)
      @theme = Theme.find(params[:id])
    end

    # rubocop:disable Metrics/AbcSize
    def update
      authorize(Theme)
      @theme = Theme.find(params[:id])
      if @theme.update(permitted_params)
        flash.now[:notice] = success_message(@theme, _('updated'))
      else
        flash.now[:alert] = failure_message(@theme, _('update'))
      end
      render :edit
    end
    # rubocop:enable Metrics/AbcSize

    def destroy
      authorize(Theme)
      @theme = Theme.find(params[:id])
      if @theme.destroy
        msg = success_message(@theme, _('deleted'))
        redirect_to super_admin_themes_path, notice: msg
      else
        flash.now[:alert] = failure_message(@theme, _('delete'))
        render :edit
      end
    end
    # Private instance methods

    private

    def permitted_params
      params.require(:theme).permit(:title, :description)
    end
  end
end
