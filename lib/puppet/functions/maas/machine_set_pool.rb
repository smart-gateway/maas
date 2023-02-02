# frozen_string_literal: true
require "uri"
require "net/http"

Puppet::Functions.create_function(:'maas::machine_set_pool') do
  dispatch :machine_set_pool do
    param 'String',  :server
    param 'String',  :consumer_token
    param 'String',  :auth_token
    param 'String',  :auth_signature
    param 'String',  :machine_id
    param 'String',  :pool_name
  end
  def machine_set_pool(server, consumer_token, auth_token, auth_signature, machine_id, pool_name)
    url = URI("http://#{server}:5240/MAAS/api/2.0/machines/#{machine_id}/")

    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Put.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    request["Content-Type"] = "application/json"
    body = {
      "pool": pool_name,
    }
    request.body = JSON.dump(body)
    response = http.request(request)
    return response
  end
end

