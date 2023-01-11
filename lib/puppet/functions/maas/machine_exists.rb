require "uri"
require "net/http"

Puppet::Functions.create_function(:'maas::machine_exists') do
  dispatch :machine_exists do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :machine_name
  end
  def machine_exists(server, consumer_token, auth_token, auth_signature, machine_name)
    # url = URI("http://#{server}:5240/MAAS/api/2.0/machines/")
    #
    # http = Net::HTTP.new(url.host, url.port)
    # nonce = rand(10 ** 30).to_s.rjust(30,'0')
    # request = Net::HTTP::Post.new(url)
    # request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"#{auth_signature}\""
    # request["Content-Type"] = "application/json"
    # body = {
    #   "architecture": machine_architecture,
    #   "min_hwe_kernel": "",
    #   "mac_addresses": machine_mac_address,
    #   "hostname": machine_name,
    #   "description": machine_description,
    #   "commission": true,
    #   "testing_scripts": "none",
    #   "domain": machine_domain
    # }
    # body.merge!(power_parameters)
    # request.body = JSON.dump(body)
    # response = http.request(request)
    # return response
    return false
  end
end