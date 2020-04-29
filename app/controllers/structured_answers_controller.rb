# frozen_string_literal: true

class StructuredAnswersController < ApplicationController

    #after_action :verify_authorized

    def create_or_update
        @plan = Plan.find(params[:plan_id])
        type = params[:type]
        obj_list = []
        parent_id = nil
        #authorize @plan


        case type
        when "partner"
            data = partner_params
            dmp_id = data.delete(:dmp_id)
            parent_id = data.delete(:parent_id)
            fragment = Fragment::Partner.create(
                dmp_id: dmp_id,
                parent_id: parent_id,
                structured_data_schema: StructuredDataSchema.find_by(classname: "partner"),
                data: data
            )
            obj_list = Fragment::Partner.where(dmp_id: dmp_id)
        when "funding"
            data = funding_params
            dmp_id = data.delete(:dmp_id)
            parent_id = data.delete(:parent_id)
            fragment = Fragment::Funding.create(
                dmp_id: dmp_id,
                parent_id: parent_id,
                structured_data_schema: StructuredDataSchema.find_by(classname: "funding"),
                data: data
            )
            obj_list = Fragment::Funding.where(dmp_id: dmp_id)
        else
        end

        render json: { 
            "type" => type,
            "html" => render_to_string(partial: 'plans/plan_details/linked_fragment_list', locals: {
                        plan: @plan,
                        parent_id: parent_id,
                        obj_list: obj_list,
                        type: type
              })
        }
    end

    def destroy 
        @plan = Plan.find(params[:plan_id])
        fragment = StructuredAnswer.find(params[:id])
        type = fragment.classname
        parent_id = fragment.parent_id
        obj_list = Fragment::Partner.where(dmp_id: fragment.dmp_id)
        
        if fragment.destroy
            render json: { 
                "type" => type,
                "html" => render_to_string(partial: 'plans/plan_details/linked_fragment_list', locals: {
                            plan: @plan,
                            parent_id: parent_id,
                            obj_list: obj_list,
                            type: type
                })
            }
        end
    end

    private
    def funding_params
        params.require(:structured_answer)
              .permit(:dmp_id, :parent_id, :fundingStatus,
                      funder: [:name, :dataPolicyUrl, funderId: [:value, :idType]],
                      grantId: [:value, :idType])
    end
   
    def partner_params
        params.require(:structured_answer)
              .permit(:dmp_id, :parent_id, :name, :dataPolicyUrl,
                      orgId: [:value, :idType])
    end
end