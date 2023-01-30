# frozen_string_literal: true
require "uri"
require "net/http"

Puppet::Functions.create_function(:'maas::machine_set_zone') do
  dispatch :machine_set_zone do
    param 'String',  :server
    param 'String',  :consumer_token
    param 'String',  :auth_token
    param 'String',  :auth_signature
    param 'String',  :machine_name
    param 'String',  :zone_name
  end
  def machine_set_zone(server, consumer_token, auth_token, auth_signature, machine_name, zone_name)
    url = URI("http://#{server}:5240/MAAS/api/2.0/machines/op-set_zone")

    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Post.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    request["Content-Type"] = "application/json"
    body = {
      "nodes": machine_name,
      "zone": zone_name,
    }
    request.body = JSON.dump(body)
    response = http.request(request)
    return response
  end
end

