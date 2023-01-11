require "uri"
require "net/http"

Puppet::Functions.create_function(:'maas::fabric_get_default_vlan') do
  dispatch :fabric_get_default_vlan do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :fabric_name
  end
  def fabric_get_default_vlan(server, consumer_token, auth_token, auth_signature, fabric_name)
    url = URI("http://#{server}:5240/MAAS/api/2.0/fabrics/")

    http = Net::HTTP.new(url.host, url.port);
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    response = http.request(request)
    data = JSON.parse(response.read_body)

    data.each do |fabric|
      if fabric['name'] == fabric_name
        return fabric['vlans'][0]['id']
      end
    end

    return nil
  end
end