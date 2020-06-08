# frozen_string_literal: true

class StructuredAnswersController < ApplicationController

  after_action :verify_authorized

  # Instanciates a new structured answer/fragment
  def new
    @fragment = StructuredAnswer.new
    @fragment.structured_data_schema = StructuredDataSchema.find(params[:schema_id])
    authorize @fragment
    render layout: false
  end
  
  def edit
    @fragment = StructuredAnswer.find(params[:id])
    authorize @fragment
    render layout: false
  end

  def create
    form_data = permitted_params.select { |k, v| schema_params(flat = true).include?(k) }
    @fragment = StructuredAnswer.create(
      structured_data_schema: StructuredDataSchema.find(permitted_params[:schema_id]),
      data: data_reformater(json_schema, form_data)
    )
    authorize @fragment
    render json: { id: @fragment.id }
  end
  
  def update
    @fragment = StructuredAnswer.find(params[:id])
    form_data = permitted_params.select { |k, v| schema_params(flat = true).include?(k) }
    @fragment.update(data: data_reformater(json_schema, form_data))
    authorize @fragment
    render json: { id: @fragment.id }
  end

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

    # Gets fragment from a given id
    def get_fragment
      @fragment = StructuredAnswer.find(params[:id])
      authorize @fragment

      if @fragment.present?
        render json: @fragment.data
      end
    end

    private

    def json_schema
      StructuredDataSchema.find(params['structured_answer']['schema_id']).schema
    end

    # Get the parameters conresponding to the schema
    def schema_params(schema, flat = false)
      s_params = schema.generate_strong_params(flat)
      params.require(:answer).permit(s_params)
    end

    def permitted_params
      permit_arr = [:id, :dmp_id, :parent_id, :schema_id]
      permit_arr.append(schema_params)
      params.require(:structured_answer).permit(permit_arr)
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