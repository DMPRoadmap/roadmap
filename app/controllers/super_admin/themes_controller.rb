# frozen_string_literal: true

module SuperAdmin

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
        flash.now[:notice] = success_message(_("created"), _("theme"))
        render :edit
      else
        flash.now[:alert] = failure_message(_("create"), _("theme"))
        render :new
      end
    end

    def edit
      authorize(Theme)
      @theme = Theme.find(params[:id])
    end

    def update
      authorize(Theme)
      @theme = Theme.find(params[:id])
      if @theme.update_attributes(permitted_params)
        flash.now[:notice] = success_message(_("updated"), _("theme"))
      else
        flash.now[:alert] = failure_message(_("update"), _("theme"))
      end
      render :edit
    end

    def destroy
      authorize(Theme)
      @theme = Theme.find(params[:id])
      if @theme.destroy
        msg = success_message(_("deleted"), _("theme"))
        redirect_to super_admin_themes_path, notice: msg
      else
        flash.now[:alert] = failure_message(_("delete"), _("theme"))
        redner :edit
      end
    end

    # Private instance methods
    private

    def permitted_params
      params.require(:theme).permit(:title, :description)
    end

  end

end
