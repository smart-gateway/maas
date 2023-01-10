# frozen_string_literal: true
require "uri"
require "net/http"

Puppet::Functions.create_function(:'maas::get_machines') do

  def get_machines()
    url = URI("http://puppet.edge.lan:5240/MAAS/api/2.0/machines/")

    http = Net::HTTP.new(url.host, url.port);
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"wzKJH2WQJQ2QVYWjqZ\",oauth_token=\"SLFU2E9EqjMwUmJY4V\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"1673393600\",oauth_nonce=\"HH4LUSureA3\",oauth_version=\"1.0\",oauth_signature=\"%26XRnrfpxugwyFayLPu8Aqya4jMDxwMCSv\""

    response = http.request(request)
    return response.read_body
  end
end

