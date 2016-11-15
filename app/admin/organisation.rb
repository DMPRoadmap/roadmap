# [+Project:+] DMPRoadmap
# [+Description:+]
#
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register Organisation do
	permit_params :abbreviation, :banner_file_id, :description, :logo_file_id, :name, :target_url, :organisation_type_id, :wayfless_entity, :parent_id

	 menu :priority => 14, :label => proc{I18n.t('admin.org')}, :parent => "Organisations management"

	index do
        column I18n.t('admin.org_title'), :sortable => :name do |ggn|
            link_to ggn.name, [:admin, ggn]
        end
        column I18n.t('admin.abbrev'), :sortable => :abbreviation do |ggn|
            if !ggn.abbreviation.nil?
                link_to ggn.abbreviation, [:admin, ggn]
            else
                '-'
            end
        end
        column I18n.t('admin.org_type'), :sortable => :organisation_type_id do |org_type|
            if !org_type.organisation_type_id.nil? then
                link_to org_type.organisation_type.name, [:admin, org_type]
            end
        end

         actions
    end


    #show details of an organisation
    show do
        resource.check_api_credentials
		attributes_table do
			row I18n.t('admin.org_title'), :sortable => :name do |gn|
				if !gn.name.nil? then
                    link_to gn.name, [:admin, gn]
                end
            end
			row I18n.t('admin.abbrev'), :abbreviation do |ggn|
                if !ggn.abbreviation.nil?
                    link_to ggn.abbreviation, [:admin, ggn]
                else
                    '-'
                end
			end
			row :sort_name
			row I18n.t('admin.org_type'), :organisation_type_id do |org_type|
				if !org_type.organisation_type_id.nil? then
                    link_to org_type.organisation_type.name, [:admin, org_type]
                end
            end
            row :banner_text do |banner|
                if !banner.banner_text.nil? then
                    banner.banner_text.html_safe
                end
            end
        #    row :target_url
            row :logo_file_name
            row :wayfless_entity
            row I18n.t('admin.token_permission_type') do
                (organisation.token_permission_types.map{|tpt| link_to tpt.token_type, [:admin, tpt]}).join(', ').html_safe
            end
            row :created_at
            row :updated_at
		end
	end

	#templates sidebar
 	sidebar I18n.t('admin.templates'), :only => :show, :if => proc { organisation.dmptemplates.count >= 1} do
	 	table_for organisation.dmptemplates.order("title asc") do |temp|
	 		column :title do |dmptemp|
                link_to dmptemp.title, [:admin, dmptemp]
            end
            column :published
	 	end
	end

	#form
    form do |f|
        f.inputs "Details" do
            f.input :name
            f.input :abbreviation
            f.input :sort_name
            f.input :organisation_type_id, :label => I18n.t('admin.org_type'), :as => :select, :collection => OrganisationType.order('name').map{|orgt|[orgt.name, orgt.id]}
        #    f.input :target_url
            f.input :banner_text
            f.input :logo_file_name
            f.input :wayfless_entity
            f.input :token_permission_types, label: I18n.t('admin.token_permission_type'),
                    as: :select, multiple: true, include_blank: I18n.t('helpers.none'),
                    collection: TokenPermissionType.order(:token_type).map{|token| [token.token_type, token.id]},
                    hint: I18n.t('admin.choose_api_permissions')
        #    f.input :parent_id, :label => I18n.t('admin.org_parent'), :as => :select, :collection => Organisation.find(:all, :order => 'name ASC').map{|orgp|[orgp.name, orgp.id]}
        #    f.input :stylesheet_file_id
        end
        f.actions
    end


	 controller do
		def permitted_params
		  params.permit!
		end
  end


end
