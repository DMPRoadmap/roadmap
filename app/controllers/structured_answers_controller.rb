# frozen_string_literal: true

class StructuredAnswersController < ApplicationController

  #after_action :verify_authorized

  def create_or_update
    @plan = Plan.find(params[:plan_id])
    p_params = permitted_params()
    type = params[:type]
    data = nil
    case type
    when "partner"
      data = partner_params
    when "funding"    
      data = funding_params
    end

    # rubocop:disable BlockLength
    StructuredAnswer.transaction do
      if p_params[:id].empty?
        @fragment = StructuredAnswer.new(
              dmp_id: p_params[:dmp_id],
              parent_id: p_params[:parent_id],
              structured_data_schema: StructuredDataSchema.find_by(classname: type),
              data: data
        )
        @fragment.classname = type
        authorize @fragment
        @fragment.save!
      else
        @fragment = StructuredAnswer.find_by!({ 
          id: p_params[:id],
          dmp_id: p_params[:dmp_id]
        })
        authorize @fragment
        @fragment.update(
          data: data
        )
      end
    end
        
    if @fragment.present?
      obj_list = StructuredAnswer.where(
          dmp_id: @fragment.dmp_id,
          classname: type
      )
      render json: { 
          "type" => type,
          "html" => render_to_string(partial: 'plans/plan_details/linked_fragment_list', locals: {
                      plan: @plan,
                      parent_id: @fragment.parent_id,
                      obj_list: obj_list,
                      type: type
        })
      }
      end
    end

    def destroy 
      @plan = Plan.find(params[:plan_id])
      @fragment = StructuredAnswer.find(params[:id])
      type = @fragment.classname
      parent_id = @fragment.parent_id
      obj_list = StructuredAnswer.where(dmp_id: @fragment.dmp_id, classname: type)
        
      authorize @fragment
      if @fragment.destroy
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
    def permitted_params
        params.require(:structured_answer)
              .permit(:id, :dmp_id, :parent_id)
    end

    def funding_params
        params.require(:structured_answer)
              .permit(:fundingStatus,
                      funder: [:name, :dataPolicyUrl, funderId: [:value, :idType]],
                      grantId: [:value, :idType])
    end
   
    def partner_params
        params.require(:structured_answer)
              .permit(:name, :dataPolicyUrl,
                      orgId: [:value, :idType])
    end
end