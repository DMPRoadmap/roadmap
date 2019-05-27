module Arphaable

  private

  def arpha_api_post(action:, **params)
    RestClient.post(Arpha::BASE, params.merge(action: action), { content_type: :xml })
  end

  def parse_arpha_xml(xml:, node: )
    value = Nokogiri(xml.to_s).xpath("//result/#{node}").text
    value.presence || raise("Couldn't find node '#{node}' in body #{xml}")
  end

end