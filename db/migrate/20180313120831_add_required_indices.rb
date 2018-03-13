class AddRequiredIndices < ActiveRecord::Migration
  def change
    #answers    
    add_index :answers, :question_id
    add_index :answers, :plan_id          

    #perms
    remove_index :perms, name: :index_perms_on_name
    remove_index :perms, name: :index_roles_on_name_and_resource_type_and_resource_id

    #plans_guidance_groups
    add_index :plans_guidance_groups, [:guidance_group_id, :plan_id]

  end
end

