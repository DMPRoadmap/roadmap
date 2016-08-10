ActiveAdmin.register TokenPermissionType do
  permit_params :token_type, :text_desription

  menu priority: 40, label: proc{ I18n.t('admin.token_permission_type')}, parent: "Api"

  # TODO: Find better fix for the undefined method xxx_id_eq
  remove_filter :org_token_permissions

  index do
    column I18n.t('admin.token_permission_type'), sortable: :token_type do |n|
      link_to n.token_type, [:admin, n]
    end
    column I18n.t('admin.permission_description') do |n|
      link_to n.text_desription, [:admin, n]
    end

    actions
  end

  show do
    attributes_table do
      row :token_type
      row :text_desription
    end
  end

  controller do
    def permitted_params
      params.permit!
    end
  end

end
