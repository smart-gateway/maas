# frozen_string_literal: true
require "uri"
require "net/http"

Puppet::Functions.create_function(:'maas::machine_create') do
  dispatch :machine_create do
    param 'String',  :server
    param 'String',  :consumer_token
    param 'String',  :auth_token
    param 'String',  :auth_signature
    param 'String',  :machine_name
    param 'String',  :machine_domain
    param 'String',  :machine_architecture
    param 'String',  :machine_mac_address
    param 'String',  :machine_description
    param 'Boolean', :machine_commission
    param 'Boolean', :machine_deployed
    param 'String',  :power_type
    param 'Hash',    :power_parameters
  end
  def machine_create(server, consumer_token, auth_token, auth_signature, machine_name, machine_domain, machine_architecture, machine_mac_address, machine_description, machine_commission, machine_deployed, power_type, power_parameters)
    url = URI("http://#{server}:5240/MAAS/api/2.0/machines/")

    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Post.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    request["Content-Type"] = "application/json"
    body = {
      "architecture": machine_architecture,
      "min_hwe_kernel": "",
      "mac_addresses": machine_mac_address,
      "hostname": machine_name,
      "description": machine_description,
      "commission": machine_commission,
      "deployed": machine_deployed,
      "testing_scripts": "none",
      "domain": machine_domain,
      "power_type": power_type,
    }
    body.merge!(power_parameters)
    request.body = JSON.dump(body)
    response = http.request(request)
    return response
  end
end

