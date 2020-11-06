# frozen_string_literal: true

module UsageHelper

  def prep_data_for_yearly_users_chart(data:)
    default_chart_prep(data: data)
  end

  def prep_data_for_yearly_plans_chart(data:)
    default_chart_prep(data: data)
  end

  # The bar graph for 'plans by template' has multiple X variables (templates)
  # for each point on the Y axis (date) so we need to format the information
  # appropriately by passing along the labels for the Y axis and the datasets
  # for the X axis
  # rubocop:disable Metrics/AbcSize
  def prep_data_for_template_plans_chart(data:, subset: "by_template")
    last_month = Date.today.last_month.end_of_month.strftime("%b-%y")
    return { labels: [last_month], datasets: [] }.to_json if data.blank? || data.empty?

    datasets = {}
    # Sort this chart's date by date desacending
    data = data.map { |hash| JSON.parse(hash) }
               .sort { |a, b| b["date"] <=> a["date"] }
    # Extract all of the dates as month abbreviation - year (e.g. Dec-19)
    labels = data.map { |rec| prep_date_for_charts(date: rec["date"]) }

    # Loop through the data and organize the datasets by template instead of date
    data.each do |rec|
      date = prep_date_for_charts(date: rec["date"])
      rec[subset].each do |template|
        # We need a placeholder for each month/year - template combo. The
        # default is to assume that there are zero plans for that month/year + template
        dflt = {
          label: template["name"],
          backgroundColor: random_rgb,
          data: labels.map { |lbl| { x: 0, y: lbl } }
        }

        template_hash = datasets.fetch(template["name"], dflt)

        # Replace any of the month/year plan counts for this template IF it has
        # any plans defined
        template_hash[:data] = template_hash[:data].map do |dat|
          dat[:y] == date ? { x: template["count"] + dat[:x], y: dat[:y] } : dat
        end
        datasets[template["name"]] = template_hash
      end
    end

    # The Chart needs a separate labels array and a datasets hash
    {
      datasets: datasets.map { |_k, v| v },
      labels: labels
    }.to_json
  end
  # rubocop:enable Metrics/AbcSize

  def plans_per_template_ranges
    [
      [_("Last month"), Date.today.last_month.end_of_month],
      [_("Last 3 months"), Date.today.months_ago(3).end_of_month],
      [_("Last 6 months"), Date.today.months_ago(6).end_of_month],
      [_("Last 9 months"), Date.today.months_ago(9).end_of_month],
      [_("Last 12 months"), Date.today.months_ago(12).end_of_month]
    ]
  end

  def default_chart_prep(data:)
    hash = {}
    data.map { |rec| JSON.parse(rec) }.each do |rec|
      date = prep_date_for_charts(date: rec["date"])
      hash[date] = hash.fetch(date, 0) + rec["count"].to_i
    end
    hash
  end

  def prep_date_for_charts(date:)
    date.is_a?(Date) ? date.strftime("%b-%y") : Date.parse(date).strftime("%b-%y")
  end

  def random_rgb
    "rgb(#{rand(256)},#{rand(256)},#{rand(256)})"
  end

end
