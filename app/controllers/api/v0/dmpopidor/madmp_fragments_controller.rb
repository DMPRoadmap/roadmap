# frozen_string_literal: true
require 'jsonpath'

class Api::V0::Dmpopidor::MadmpFragmentsController < Api::V0::BaseController
    before_action :authenticate

    def show 
        @fragment = MadmpFragment.find(params[:id])
        # check if the user has permissions to use the templates API
        unless Api::V0::Dmpopidor::MadmpFragmentPolicy.new(@user, @fragment).show?
          raise Pundit::NotAuthorizedError
        end

        fragment_data = nil
        if query_params[:mode] == "slim" 
          fragment_data = @fragment.data
        else
          fragment_data = @fragment.get_full_fragment
        end

        fragment_data = select_property(fragment_data, query_params[:property])

        respond_with fragment_data
    end


    private 
    
    def select_property(fragment_data, property_name)
      if property_name.present? 
        fragment_data = JsonPath.on(fragment_data, "$..#{property_name}")
      end
      fragment_data
    end

    def query_params
      params.permit(:mode, :property)
    end
end