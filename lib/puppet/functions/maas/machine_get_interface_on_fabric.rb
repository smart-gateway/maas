# frozen_string_literal: true
require "uri"
require "json"
require "net/http"

Puppet::Functions.create_function(:'maas::machine_get_interface_on_fabric') do
  dispatch :machine_get_interface_on_fabric do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :system_id
    param 'String', :fabric
  end

  def machine_get_interface_on_fabric(server, consumer_token, auth_token, auth_signature, system_id, fabric)
    url = URI("http://#{server}:8180/plugins/maas/machine/interfaces?id=#{system_id}")
    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30, '0')

    request = Net::HTTP::Get.new(url)
    request["Authorization"] =
      "OAuth oauth_consumer_key=\"#{consumer_token}\"," \
        "oauth_token=\"#{auth_token}\"," \
        "oauth_signature_method=\"PLAINTEXT\"," \
        "oauth_timestamp=\"#{Time.now.to_i}\"," \
        "oauth_nonce=\"#{nonce}\"," \
        "oauth_version=\"1.0\"," \
        "oauth_signature=\"%26#{auth_signature}\""

    response = http.request(request)
    data = JSON.parse(response.read_body)

    interfaces = data.dig('response', 0, 'interfaces')
    return nil unless interfaces.is_a?(Array)

    interfaces.each do |interface|
      vlan = interface['vlan']
      next if vlan.nil?

      if vlan['fabric'] == fabric
        return interface['id']
      end
    end

    nil
  end
end
