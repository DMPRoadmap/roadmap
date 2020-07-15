# frozen_string_literal: true

# == Schema Information
#
# Table name: stats
#
#  id         :integer          not null, primary key
#  count      :bigint(8)        default(0)
#  date       :date             not null
#  details    :text
#  filtered   :boolean          default(FALSE)
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  org_id     :integer
#

require "set"

class StatCreatedPlan < Stat

  serialize :details, JSON

  def by_template
    parse_details.fetch("by_template", [])
  end

  def using_template
    parse_details.fetch("using_template", [])
  end

  def to_json(options = nil)
    super(methods: [:by_template, :using_template])
  end

  def parse_details
    return JSON.parse({}) unless details.present?

    json = details.is_a?(String) ? JSON.parse(details) : details
  end

  class << self

    def to_csv(created_plans, details: { by_template: false, sep: "," })
      if details[:by_template]
        to_csv_by_template(created_plans, details[:sep])
      else
        super(created_plans, details[:sep])
      end
    end

    private

    def to_csv_by_template(created_plans, sep = ",")
      template_names = lambda do |created_plans|
        unique = Set.new
        created_plans.each do |created_plan|
          created_plan.by_template&.each do |name_count|
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
        created_plan.by_template&.each do |name_count|
          tuple[name_count.fetch("name")] = name_count.fetch("count")
        end
        tuple[:Count] = created_plan.count
        tuple
      end
      Csvable.from_array_of_hashes(data, false, sep)
    end

  end

end
