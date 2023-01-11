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
    url = URI("http://#{server}:5240/MAAS/api/2.0/machines/")

    http = Net::HTTP.new(url.host, url.port);
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    response = http.request(request)
    data = JSON.parse(response.read_body)

    data.each do |host|
      if host['hostname'] == machine_name
        return true
      end
    end

    return false
  end
end