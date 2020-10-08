# frozen_string_literal: true

class Api::V0::Dmpopidor::MadmpFragmentsController < Api::V0::BaseController
    before_action :authenticate

    def show 
        @fragment = MadmpFragment.find(params[:id])
        # check if the user has permissions to use the templates API
        unless Api::V0::Dmpopidor::MadmpFragmentPolicy.new(@user, @fragment).show?
          raise Pundit::NotAuthorizedError
        end

        respond_with @fragment.get_full_fragment
    end

end