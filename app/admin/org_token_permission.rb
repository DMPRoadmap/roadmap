ActiveAdmin.register OrgTokenPermission do
  permit_params :organisation_id, :token_permission_type_id

  menu priority: 40, label: proc{ I18n.t('admin.org_token_permission')}, parent: "Api"

  index do
    column I18n.t('admin.org') do |n|
      link_to n.organisation, [:admin,n]
    end
    column I18n.t('admin.token_permission') do |n|
      link_to n.token_permission_type, [:admin,n]
    end

    actions
  end

  show do
    attributes_table do
      row :organisation_id
      row :token_permission_type_id
    end
  end

  controller do
    def permitted_params
      params.permit!
    end
  end


end
