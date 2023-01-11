require "uri"
require "net/http"

class String
  def is_i?
    !!(self =~ /\A[-+]?[0-9]+\z/)
  end
end


Puppet::Functions.create_function(:'maas::get_interfaces_on_default_fabric') do
  dispatch :get_interfaces_on_default_fabric do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :system_id
  end
  def get_interfaces_on_default_fabric(server, consumer_token, auth_token, auth_signature, system_id)
    url = URI("http://#{server}:5240/MAAS/api/2.0/machines/#{system_id}")

    http = Net::HTTP.new(url.host, url.port);
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    response = http.request(request)
    data = JSON.parse(response.read_body)

    interface_ids = []
    data['interface_set'].each do |interface|
      fabric = interface['vlan']['fabric'].gsub("fabric-", "")
      if fabric.is_i?
        interface_ids.append(interface['id'])
      end
    end

    return interface_ids
  end
end