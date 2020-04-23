module Dmpopidor
  module Models
    module Plan



      # CHANGE : Fix to creator display
      def owner
        usr_id = Role.where(plan_id: id, active: true)
                      .creator
                      .order(:created_at)
                      .pluck(:user_id).first
        User.find(usr_id)
      end

      # CHANGES : ADDED RESEARCH OUTPUT SUPPORT
      # The most recent answer to the given question id optionally can create an answer if
      # none exists.
      #
      # qid               - The id for the question to find the answer for
      # roid               - The id for the research output to find the answer for
      # create_if_missing - If true, will genereate a default answer
      #                     to the question (defaults: true).
      #
      # Returns Answer
      # Returns nil
      def answer(qid, create_if_missing = true, roid = nil)
        answer = answers.where(question_id: qid, research_output_id: roid).order("created_at DESC").first
        question = Question.find(qid)
        if answer.nil? && create_if_missing
          answer             = Answer.new
          answer.plan_id     = id
          answer.question_id = qid
          answer.text        = question.default_value
          default_options    = []
          question.question_options.each do |option|
            default_options << option if option.is_default
          end
          answer.question_options = default_options
        end
        answer
      end


      # The number of research outputs for a plan.
      #
      # Returns Integer
      def num_research_outputs
        research_outputs.count
      end


      # Return the JSON Fragment linked to the Plan
      #
      # Returns JSON
      def json_fragment
        Fragment::Dmp.where("(data->>'plan_id')::int = ?", id).first
      end

      # Create the Project JSON Fragment
      #
      # Returns JSON
      def create_project_json(project = nil)
        fragment = nil
        if project.nil?
          fragment = {
            "title" => self.title,
            "description" => self.description
          }

        else 
          fragment = {
            "title" => project["project_title"],
            "acronym" => project["project_acronym"],
            "description" => project["project_description"],
            "projectId" => project["project_id"],
            "startDate" => project["project_start_date"],
            "endDate" => project["project_end_date"],
            "experimentalPlanUrl" => project["experimental_plan_url"],
            "principalInvestigator" => project["principalInvestigator"]
          }

        end
        fragment
      end

      # Create the Meta JSON Fragment
      #
      # Returns JSON
      def create_meta_json(meta = nil)
        fragment = nil
        if meta.nil?
          fragment = {
            "creationDate" => self.created_at,
            "lastModifiedDate" => self.updated_at
          }
        else
          fragment = meta.merge({
            "creationDate" => self.created_at,
            "lastModifiedDate" => self.updated_at
          })
        end
        fragment
      end

      # Create a Person JSON Fragment if it doesn't exist
      # 
      # Returns JSON
      def create_or_update_person_fragment(person)
        dmp_fragment = self.json_fragment()
        person_fragment = nil
        ## TODO : Permettre la mise à jour d'une personne
        unless person[:mbox].empty?
          person_fragment = dmp_fragment.persons.where(
            "data->>'mbox' = ?", person[:mbox]
          ).first_or_create do |fragment|
            fragment.data = person
            fragment.dmp_id = dmp_fragment.id
            fragment.save
          end 
        end
        person_fragment
      end
 
      def create_plan_fragments
        dmp_fragment = Fragment::Dmp.create(
          data: {
            "plan_id" => self.id
          }
        )
        
        Fragment::Project.create(
          data: create_project_json(),
          dmp_id: dmp_fragment.id,
          parent_id: dmp_fragment.id
        )

        Fragment::Meta.create(
          data: create_meta_json(),
          dmp_id: dmp_fragment.id,
          parent_id: dmp_fragment.id
        )  
      end

      def update_plan_fragments(meta, project)
        dmp_fragment = self.json_fragment()

        contact_fragment = create_or_update_person_fragment(meta.delete(:contact))
        principal_investigator_fragment = create_or_update_person_fragment(project.delete(:principalInvestigator))

        meta[:contact] = {
          "dbId" => contact_fragment ? contact_fragment.id : nil
        }
        project[:principalInvestigator] = {
          "dbId" => principal_investigator_fragment ? principal_investigator_fragment.id : nil
        }
        
        dmp_fragment.meta.update(
          data: create_meta_json(meta)
        )
        
        dmp_fragment.project.update(
          data: create_project_json(project)
        )
      end
    end 
  end
end