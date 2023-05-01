require "uri"
require "net/http"

Puppet::Functions.create_function(:'maas::machine_get_pool') do
  dispatch :machine_get_pool do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :system_id
  end
  def machine_get_pool(server, consumer_token, auth_token, auth_signature, system_id)
    #url = URI("http://#{server}:5240/MAAS/api/2.0/machines/#{system_id}/")
    url = URI("http://#{server}:8080/plugins/maas/machine/pool?host=#{machine_name}")

    http = Net::HTTP.new(url.host, url.port);
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Get.new(url)
    #request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    response = http.request(request)
    data = JSON.parse(response.read_body)

    if data.key?('pool')
      return data['pool']['name']
    else
      return nil
    end
  end
end