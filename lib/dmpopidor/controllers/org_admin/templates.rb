module Dmpopidor
  module Controllers
    module OrgAdmin
      module Templates
        # GET /org_admin/templates/:id/edit
        # CHANGES : Added Locales list for view
        def edit
          template = Template.includes(:org, :phases).find(params[:id])
          @locales = Language.all
          authorize template
          # Load the info needed for the overview section if the authorization check passes!
          phases = template.phases.includes(sections: { questions: :question_options }).
                            order("phases.number",
                                  "sections.number",
                                  "questions.number",
                                  "question_options.number").
                            select("phases.title",
                                  "phases.description",
                                  "sections.title",
                                  "questions.text",
                                  "question_options.text")
          if !template.latest?
            redirect_to org_admin_template_path(id: template.id)
          else
            render "container", locals: {
              partial_path: "edit",
              template: template,
              phases: phases,
              referrer: get_referrer(template, request.referrer) }
          end
        end



        # CHANGES : Added Locale parameter
        def template_params
          params.require(:template).permit(:title, :description, :visibility, :links, :locale)
        end
    
      end
    end
  end
end


    