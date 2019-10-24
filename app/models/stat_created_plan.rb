# frozen_string_literal: true

# == Schema Information
#
# Table name: stats
#
#  id         :integer          not null, primary key
#  count      :bigint(8)        default(0)
#  date       :date             not null
#  details    :text
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#

require "set"

class StatCreatedPlan < Stat

  serialize :details, JSON

  def any_template
    if self.details.present?
      any_template = self.details["any_template"]
    end
    return [] unless any_template.present?
    any_template
  end

  def org_template
    if self.details.present?
      org_template = self.details["org_template"]
    end
    return [] unless org_template.present?
    org_template
  end

  class << self

    def to_csv(created_plans, details: { any_template: false, org_template: false,})
      if details[:any_template]
        to_csv_by_template(created_plans, "any_template")
      elsif details[:org_template]
        to_csv_by_template(created_plans, "org_template")
      else 
        super(created_plans)
      end
    end

    private

    def to_csv_by_template(created_plans, template_filter)
      template_names = lambda do |created_plans|
        unique = Set.new
        created_plans.each do |created_plan|
          created_plan.details&.fetch(template_filter, [])&.each do |name_count|
            unique.add(name_count.fetch("name"))
          end
        end
        unique.to_a
      end.call(created_plans)

      data = created_plans.map do |created_plan|
        tuple = { Date: created_plan.date.strftime("%b %Y")  }
        template_names.reduce(tuple) do |acc, name|
          acc[name] = 0
          acc
        end
        created_plan.details&.fetch(template_filter, [])&.each do |name_count|
          tuple[name_count.fetch("name")] = name_count.fetch("count")
        end
        tuple[:Count] = created_plan.count
        tuple
      end
      Csvable.from_array_of_hashes(data, false)
    end

  end

end
