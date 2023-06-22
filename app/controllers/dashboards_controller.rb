# frozen_string_literal: true

# Controller for the React UI.
#
# This one controller action handles all routes for the React UI whose pages live under the `dashboard/` path.
# We need to do this so that on a page refresh, manual entry of a URL in the browser, a bookmark, or a link
# from one of the Rails managed pages will render the React UI.
#
# The React UI has it's own router defined in `react-app/src/App.js` which will determine what React page to render
#
class DashboardsController < ApplicationController
  def show
    # Manually handling security here since we don't have an appropriate model to tie a policy to.
    # Only an admin can currently view the new React UI. May need to remove this later
    redirect_to plans_path, alert: 'You are not authorized' and return unless current_user.can_org_admin?

    render :show, layout: 'react_application'
  end
end
