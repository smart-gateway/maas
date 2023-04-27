require "uri"
require "net/http"

Puppet::Functions.create_function(:'maas::machine_get_system_id') do
  dispatch :machine_get_system_id do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :machine_name
  end
  def machine_get_system_id(server, consumer_token, auth_token, auth_signature, machine_name)
    url = URI("http://#{server}:5240/MAAS/api/2.0/machines/?hostname=#{machine_name}")

    http = Net::HTTP.new(url.host, url.port);
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    response = http.request(request)
    data = JSON.parse(response.read_body)

    data.each do |host|
      if host['hostname'] == machine_name
        return host['system_id']
      end
    end

    Puppet.send("warning", "failed to find system_id with name: #{machine_name}")

    return nil
  end
end