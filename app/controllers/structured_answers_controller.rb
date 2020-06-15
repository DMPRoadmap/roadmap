# frozen_string_literal: true

class StructuredAnswersController < ApplicationController

  after_action :verify_authorized

  # Instanciates a new structured answer/fragment
  # def new
  #   @fragment = StructuredAnswer.new
  #   @fragment.structured_data_schema = StructuredDataSchema.find(params[:schema_id])
  #   authorize @fragment
  #   render layout: false
  # end
  
  # def edit
  #   @fragment = StructuredAnswer.find(params[:id])
  #   authorize @fragment
  #   render layout: false
  # end

  # def create
  #   form_data = permitted_params.select { |k, v| schema_params(flat = true).include?(k) }
  #   @fragment = StructuredAnswer.create(
  #     structured_data_schema: StructuredDataSchema.find(permitted_params[:schema_id]),
  #     data: data_reformater(json_schema, form_data)
  #   )
  #   authorize @fragment
  #   render json: { id: @fragment.id }
  # end
  
  def update
    @fragment = StructuredAnswer.find(params[:id])
    form_data = permitted_params.select { |k, v| schema_params(flat = true).include?(k) }
    @fragment.update(data: data_reformater(json_schema, form_data))
    authorize @fragment
    render json: { id: @fragment.id }
  end

  def create_or_update
    p_params = permitted_params()
    classname = params[:classname]
    schema = StructuredDataSchema.find_by(classname: classname)
    data = schema_params(schema)
    

    # rubocop:disable BlockLength
    StructuredAnswer.transaction do
      if p_params[:id].empty?
        @fragment = StructuredAnswer.new(
              dmp_id: p_params[:dmp_id],
              parent_id: p_params[:parent_id],
              structured_data_schema: schema,
              data: data
        )
        @fragment.classname = classname
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
          parent_id: @fragment.parent_id,
          classname: classname
      )
      render json: { 
          "fragment_id" =>  @fragment.parent_id,
          "classname" => classname,
          "html" => render_to_string(partial: 'shared/dynamic_form/linked_fragment/list', locals: {
                      parent_id: @fragment.parent_id,
                      obj_list: obj_list,
                      classname: classname
        })
      }
    end
  end



  def new_edit_linked_fragment
    @classname = params[:classname]
    @parent_fragment = StructuredAnswer.find(params[:parent_id])
    @schema = StructuredDataSchema.find_by(classname: @classname)
    @fragment = nil 
    if params[:fragment_id] 
      @fragment = StructuredAnswer.find(params[:fragment_id]) 
    else
      @fragment = StructuredAnswer.new(
          dmp_id: @parent_fragment.dmp_id,
          parent_id: @parent_fragment.id
        )
    end
    authorize @fragment
    respond_to do |format|
      format.html
      format.js { render :partial => "shared/dynamic_form/linked_fragment" }
    end
  end

  def destroy 
    @fragment = StructuredAnswer.find(params[:id])
    classname = @fragment.classname
    parent_id = @fragment.parent_id
    dmp_id = @fragment.dmp_id

    authorize @fragment
    if @fragment.destroy
      obj_list = StructuredAnswer.where(
        dmp_id: dmp_id,
        parent_id: parent_id,
        classname: classname
      )
      
      render json: {
        "fragment_id" =>  parent_id,
        "classname" => classname,
        "html" => render_to_string(partial: 'shared/dynamic_form/linked_fragment/list', locals: {
                                      parent_id: @fragment.parent_id,
                                      obj_list: obj_list,
                                      classname: classname
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
    params.require(:structured_answer).permit(s_params)
  end

  def permitted_params
    permit_arr = [:id, :dmp_id, :parent_id, :schema_id]
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