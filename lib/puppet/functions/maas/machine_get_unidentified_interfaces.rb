require "uri"
require "json"
require "net/http"

Puppet::Functions.create_function(:'maas::machine_get_unidentified_interfaces') do
  dispatch :machine_get_unidentified_interfaces do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :system_id
  end

  def machine_get_unidentified_interfaces(server, consumer_token, auth_token, auth_signature, system_id)
    url = URI("http://#{server}:5240/MAAS/api/2.0/machines/#{system_id}/")

    http = Net::HTTP.new(url.host, url.port);
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    response = http.request(request)
    data = JSON.parse(response.read_body)
    jdata = JSON.pretty_generate(data)
    Puppet.send("warning", "data: #{jdata}")
    interface_ids = []
    if !data.nil? && data.key?('interface_set')
      data['interface_set'].each do |interface|
        fabric = interface['vlan']['fabric'].gsub("fabric-", "")
        if fabric.to_i.to_s == fabric
          interface_ids.append(interface['id'])
        end
      end
    end

    return interface_ids
  end
end