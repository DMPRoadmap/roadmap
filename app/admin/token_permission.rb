ActiveAdmin.register TokenPermission do
  permit_params :api_token, :token_permission_type_id, :user_id

  #TODO: make migration to add user_id to the model so we can have the relationship...

  menu priority:25, label: proc{ I18n.t('admin.token_permission')}, parent: "Api"

  index do
    column I18n.t('admin.user') do |n|
      link_to n.user.email, [:admin,n]
    end
    column I18n.t('admin.token_permission') do |n|
      link_to n.token_permission_type, [:admin, n]
    end
    actions
  end

  show do
    attributes_table do
      row :user_id
      row :token_permission_type_id
      row :api_token
    end
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end
