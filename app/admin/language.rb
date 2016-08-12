# [+Project:+] DMPonline
# [+Description:+]
#
# [+Created:+] 12/08/2016
# [+Copyright:+] Digital Curation Centre

ActiveAdmin.register Language do
  permit_params :language_id, :name, :abbreviation, :default_language

  menu :priority => 10, :label => proc { I18n.t('admin.language') }

  index do
    column I18n.t('admin.language_name'), :sortable => :name do |lang|
      link_to lang.name, [:admin, lang]
    end
    column I18n.t('admin.language_abbreviation'), :sortable => :abbreviation do |lang|
      link_to lang.abbreviation, [:admin, lang]
    end
    column I18n.t('admin.language_is_default'), :sortable => :default_language do |lang|
      if lang[:default_language]
        'Yes'
      else
        'No'
      end
    end

    actions
  end

  show do
    attributes_table do
      row :name
      row :abbreviation
      row :default_language
      row :description
    end
  end

  controller do
    def permitted_params
      params.permit!
    end
  end

end