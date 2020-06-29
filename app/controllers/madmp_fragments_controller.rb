# frozen_string_literal: true

class MadmpFragmentsController < ApplicationController

  after_action :verify_authorized

  def create_or_update
    p_params = permitted_params()
    schema = MadmpSchema.find(p_params[:schema_id])
    classname = schema.classname
    data = schema_params(schema)
    
    # rubocop:disable BlockLength
    MadmpFragment.transaction do
      if p_params[:id].empty?
        @fragment = MadmpFragment.new(
              dmp_id: p_params[:dmp_id],
              parent_id: p_params[:parent_id],
              madmp_schema: schema,
              data: data
        )
        @fragment.classname = classname
        authorize @fragment
        @fragment.save!
      else
        @fragment = MadmpFragment.find_by!({ 
          id: p_params[:id],
          dmp_id: p_params[:dmp_id]
        })
        new_data = @fragment.data.merge(data)
        authorize @fragment
        @fragment.update(
          data: new_data
        )
      end
    end
        
    if @fragment.present?
      render json: { 
          "fragment_id" =>  @fragment.parent_id,
          "classname" => classname,
          "html" => render_fragment_list(@fragment.dmp_id, @fragment.parent_id, schema.id)
      }
    end
  end



  def new_edit_linked
    @schema = MadmpSchema.find(params[:schema_id])
    @parent_fragment = MadmpFragment.find(params[:parent_id])
    @classname = @schema.classname

    @fragment = nil
    dmp_id = @parent_fragment.classname == "dmp" ? @parent_fragment.id : @parent_fragment.dmp_id
    if params[:fragment_id] 
      @fragment = MadmpFragment.find(params[:fragment_id]) 
    else
      @fragment = MadmpFragment.new(
          dmp_id: dmp_id,
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
    @fragment = MadmpFragment.find(params[:id])
    classname = @fragment.classname
    parent_id = @fragment.parent_id
    dmp_id = @fragment.dmp_id

    authorize @fragment
    if @fragment.destroy
      obj_list = MadmpFragment.where(
        dmp_id: dmp_id,
        parent_id: parent_id,
        madmp_schema_id: @fragment.madmp_schema_id
      )
      
      render json: {
        "fragment_id" =>  parent_id,
        "classname" => classname,
        "html" => render_fragment_list(dmp_id, parent_id, @fragment.madmp_schema_id)
      }
    end
  end

  # Gets fragment from a given id
  def get_fragment
    @fragment = MadmpFragment.find(params[:id])
    authorize @fragment

    if @fragment.present?
      render json: @fragment.data
    end
  end

  private

  def render_fragment_list(dmp_id, parent_id, schema_id)
    schema = MadmpSchema.find(schema_id)
    case schema.classname
    when "research_output"
      @plan = Fragment::Dmp.where(id: dmp_id).first.plan
      return render_to_string(partial: 'research_outputs/list', locals: {
        plan: @plan,
        research_outputs: @plan.research_outputs,
        readonly: false
      })

    else 
      obj_list = MadmpFragment.where(
        dmp_id: dmp_id,
        parent_id: parent_id,
        madmp_schema_id: schema.id
      )
      return render_to_string(partial: 'shared/dynamic_form/linked_fragment/list', locals: {
                  parent_id: parent_id,
                  obj_list: obj_list,
                  schema: schema
      })
    end
  end

  # Get the parameters conresponding to the schema
  def schema_params(schema, flat = false)
    s_params = schema.generate_strong_params(flat)
    params.require(:madmp_fragment).permit(s_params)
  end

  def permitted_params
    permit_arr = [:id, :dmp_id, :parent_id, :schema_id]
    params.require(:madmp_fragment).permit(permit_arr)
  end
end