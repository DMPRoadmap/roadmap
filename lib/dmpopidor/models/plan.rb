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


      def json_fragment
        Fragment::Dmp.where("(data->>'plan_id')::int = ?", id).first
      end

      def create_project_json(pi_frag_id = nil)
        {
          "title" => self.title,
          "description" => self.description,
          "grantId" => {
            "value" => self.grant_number ? self.grant_number : ""
          },
          "principalInvestigator" => pi_frag_id ? {
            "dbId" => pi_frag_id
          } : nil
        }
      end

      def create_meta_json(contact_frag_id = nil)
        {
          "dmpID" => {
            "value" => self.identifier
          },
          "contact"=> contact_frag_id ? {
            "dbId" => contact_frag_id
          } : nil ,
          "creationDate" => self.created_at,
          "lastModifiedDate" => self.updated_at
        }
      end


      private 
        def create_plan_fragments
          research_output = self.research_outputs.first

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

        def update_plan_fragments
          dmp_fragment = self.json_fragment()


          principal_investigator_fragment = dmp_fragment.persons.where(
            "data->>'mbox' = ?", self.principal_investigator_email
          ).first_or_create do |fragment|
            fragment.data = {
              "lastName" => self.principal_investigator ? self.principal_investigator : "",
              "firstName" => "",
              "mbox" => self.principal_investigator_email ? self.principal_investigator_email : "",
              "personId" => self.principal_investigator_identifier ? self.principal_investigator_identifier : "",
            }
            fragment.dmp_id = dmp_fragment.id
          end

          contact_fragment_id = nil

          if self.data_contact_email == self.principal_investigator_email || 
             self.data_contact_email.nil? || self.data_contact_email.empty?
            contact_fragment_id = principal_investigator_fragment.id
          else 
            contact_fragment = dmp_fragment.persons.where(
              "data->>'mbox' = ?", self.data_contact_email
          ).first_or_create do |fragment|
              fragment.data = {
                "lastName" => self.data_contact ? self.data_contact : "",
                "firstName" => "",
                "mbox" => self.data_contact_email ? self.data_contact_email : ""
              }
              fragment.dmp_id = dmp_fragment.id
            end
            #contact_fragment_id = contact_fragment.id
          end

          dmp_fragment.meta.update(
            data: create_meta_json(contact_fragment_id)
          )
          dmp_fragment.project.update(
            data: create_project_json(principal_investigator_fragment.id)
          )
        end
    end 
  end
end