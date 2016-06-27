module Api
  module V0
    class ProjectsController < Api::V0::BaseController
      before_action :authenticate

      swagger_controller :projects, 'Plans'

      swagger_api :create do |api|
        summary 'Returns a single guidance group item'
        notes   'Notes...'
        param :header, 'Authentication-Token', :string, :required, 'Authentication-Token'
        response :unauthorized
        response :not_found
      end

      def create
        # find the user's api_token permissions
        # then ensure that they have the permission associated with creating plans
        if has_auth "plans"
          #params[:organization_id] = Organisation.where(name: params[:template][:organization])
          # find_by returns nil if none found, find_by! raises an ActiveRecord error
          organization = Organisation.find_by name: params[:template][:organization]
          # if organization exists
          if !organization.nil?
            # if organization is funder
            if organization.organisation_type == (OrganisationType.find_by name: "Funder")
              # if organization has only 1 template
              if organization.dmptemplates.length == 1
                # set template id
                dmptemplate = organization.dmptemplates.first
              # else if params.template.name specified && params.template.name == one of organization's tempates
              elsif !organization.dmptemplates.find_by title: params[:template][:name].nil?
                # set template id
                dmptemplate = organization.templates.find_by title: params[:template][:name]
              # else error: organization has more than one template and template name unspecified
              else
                render json: 'error:"Organization has more than one template and template name unspecified or invalid"', status: 400 and return
              end
            # else error: organization specified is not a funder
            else
              render json: 'error:"Organization specified is not a funder"', status: 400 and return
            end
          # else error: organization does not exist
          else
            render json: 'error:"Organization does not exist"', status: 400 and return
          end

          # cant invite a user without having a current user because of devise :ivitable
          # after we have auth, will be able to assign an :invited_by_id
          user = User.find_by email: params[:project][:email]
          # if user does not exist
          if user.nil?
            # invite user to DMPonline
            User.invite!({email: params[:project][:email]}, ( @user))
            # set project owner to user associated w/email
            user = (User.find_by email: params[:project][:email])
          end

          # create new project with specified parameters
          @project = Project.new
          @project.title =  params[:project][:title]
          @project.dmptemplate = dmptemplate
          @project.slug = params[:project][:title]
          @project.organisation = @user.organisations.first
          @project.assign_creator(user.id)

          # if save successful, render success, otherwise show error
          if @project.save
            #render json: @project ,status: :created
            render :show, status: :created
          else
            render json: get_resource.errors, status: :unprocessable_entity
          end
        else
          render json: 'error:"You do not have authorisation to view this api endpoint"', status: 400 and return
        end
      end

      private
        def project_params
          params.require(:template).permit(:organization, :name)
          params.require(:project).permit(:title, :email)
        end
    end
  end
end
