module SuperAdmin
  class ThemesController < ApplicationController
    helper PaginableHelper
    def index
      authorize(Theme)
      render(:index, locals: { themes: Theme.all.page(1) })
    end

    def new
      authorize(Theme)
      render(:new_edit, locals: { theme: Theme.new, options: { url: super_admin_themes_path, method: :POST, title: _('New Theme') }})
    end

    def create
      authorize(Theme)
      begin
        pparams = permitted_params
        Theme.create!(pparams)
        flash[:notice] = _('Theme created successfully')
      rescue ActionController::ParameterMissing
        flash[:alert] = _('Unable to save since theme parameter is missing')
      rescue ActiveRecord::RecordInvalid => e
        flash[:alert] = e.message
      end
      redirect_to(action: :index)
    end

    def edit
      authorize(Theme)
      begin
        theme = Theme.find(params[:id])
        render(:new_edit, locals: { theme: theme, options: { url: super_admin_theme_path(theme), method: :PUT, title: _('Edit Theme') }})
      rescue ActiveRecord::RecordNotFound
        flash[:alert] = _('There is no theme associated with id %{id}') % { :id => params[:id] }
        redirect_to(action: :index)
      end
    end

    def update
      authorize(Theme)
      begin
        pparams = permitted_params
        Theme.find(params[:id]).update_attributes!(pparams)
        flash[:notice] = _('Theme updated successfully')
      rescue ActiveRecord::RecordNotFound
        flash[:alert] = _('There is no theme associated with id %{id}') % { :id => params[:id] }
      rescue ActionController::ParameterMissing
        flash[:alert] = _('Unable to save since theme parameter is missing')
      rescue ActiveRecord::RecordInvalid => e
        flash[:alert] = e.message
      end
      redirect_to(action: :index)
    end

    def destroy
      authorize(Theme)
      begin
        Theme.find(params[:id]).destroy!
        flash[:notice] = _('Successfully deleted your theme')
      rescue ActiveRecord::RecordNotFound
        flash[:alert] = _('There is no theme associated with id %{id}') % { :id => params[:id] }
      rescue ActiveRecord::RecordNotDestroyed # Unlikely to happen since we don't have callback associated to destroy! but put for safety
        flash[:alert] = _('The theme with id %{id} could not be destroyed') % { :id => params[:id] }
      end
      redirect_to(action: :index)
    end
    # Private instance methods
    private

    def permitted_params
      params.require(:theme).permit(:title, :description)
    end
  end
end
