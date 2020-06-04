module Dmpopidor
  module Concerns
    module ExportablePlan
      def prepare_coversheet
        hash = {}
        # name of owner and any co-owners
        attribution = self.owner.present? ? [self.owner.name(false)] : []
        self.roles.administrator.not_creator.each do |role|
            attribution << role.user.name(false)
        end
        hash[:attribution] = attribution
    
        # Org name of plan owner's org
        hash[:affiliation] = self.owner.present? ? self.owner.org.name : ""
        hash[:affiliation] += self.owner.present? && self.owner.department ? ", #{self.owner.department.name}" : ""
    
        # set the funder name
        hash[:funder] = self.funder_name.present? ? self.funder_name :  ""
    
        # set the template name and customizer name if applicable
        hash[:template] = self.template.title
        customizer = ""
        cust_questions = self.questions.where(modifiable: true).pluck(:id)
        # if the template is customized, and has custom answered questions
        if self.template.customization_of.present? &&
            Answer.where(plan_id: self.id, question_id: cust_questions).present?
            customizer = _(" Customised By: ") + self.template.org.name
        end
        hash[:customizer] = customizer
        hash
      end
    end
  end
end