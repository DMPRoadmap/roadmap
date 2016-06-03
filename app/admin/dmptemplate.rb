# [+Project:+] DMPonline
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre 

ActiveAdmin.register Dmptemplate do
	permit_params :title, :description, :organisation_id, :published, :is_default
	
	menu :priority => 11, :label => proc{ I18n.t('admin.template')}, :parent => "Templates management"

    # FIXME: The below member_actions only work on :export settings.
    member_action :settings do
        @template = resource
        @settings = resource.settings(:export)
    end

    member_action :update_settings, method: :put do
        new_settings = params[:settings][:export]

        settings = resource.settings(:export).tap do |s|
            s.formatting, s.max_pages = if params[:commit] != 'Reset'
            [
                new_settings[:formatting].try(:deep_symbolize_keys),
                new_settings[:max_pages].try(:to_i)
            ]
            else
                [ nil, nil ]
            end
        end

        if settings.save
            redirect_to(action: :show, flash: { notice: 'Settings updated successfully' })
        else
            settings.formatting = nil
            @template = resource
            @settings = settings
            render(action: :settings)
        end
    end

    action_item only: %i( show edit ) do
        link_to(I18n.t('helpers.settings.title'), settings_admin_dmptemplate_path(resource.id))
    end

    index do   
        column :title do |dmptemp|
            link_to dmptemp.title, [:admin, dmptemp]
        end
        column :description do |descr|
            if !descr.description.nil? then
                descr.description.html_safe
            end
        end
        column I18n.t('admin.org_title'), :sortable => :organisation_id do |org_title|
            if !org_title.organisation.nil? then
				link_to org_title.organisation.name, [:admin, org_title.organisation]
			else
				'-'
			end
        end
        column :published
        column :is_default
        
        actions defaults: true do |template|
            link_to(I18n.t('helpers.settings.title'), settings_admin_dmptemplate_path(template.id))
        end
    end
 
 
	# show Template details
	show do 
		attributes_table do
			row :title
	 		row :description do |descr|
                if !descr.description.nil? then
                    descr.description.html_safe
                end
            end
            row I18n.t('admin.org_title'), :sortable => :organisation_id do |org_title|
                if !org_title.organisation.nil? then
				link_to org_title.organisation.name, [:admin, org_title.organisation]
			else
				'-'
			end
            end
            row :published
            row :is_default
            row :created_at
            row :updated_at
        end
	end 
		 
    #phases sidebar
    sidebar I18n.t('admin.phases'), :only => :show, :if => proc { dmptemplate.phases.count >= 1} do
        table_for dmptemplate.phases.order("number asc") do |temp_phases|
            column :number
            column :title do |row|
                link_to row.title, [:admin, row]
            end	
        end
    end
			 
 	#form 	
 	form do |f|
        f.inputs "Details" do
            f.input :title
            f.input :description
            f.input :organisation_id, :label => I18n.t('admin.org_title'), 
                            :as => :select, 
                            :collection => Organisation.order('name').map{|orgp|[orgp.name, orgp.id]}
            f.input :published
            f.input :is_default
        end
        f.actions  
    end		
 
	 controller do
		def permitted_params
		  params.permit!
		end
  end
 
end

