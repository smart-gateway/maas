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
    url = URI("http://#{server}:8180/plugins/maas/machine/interfaces?id=#{system_id}")
    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30, '0')
    request = Net::HTTP::Get.new(url)

    response = http.request(request)
    data = JSON.parse(response.read_body)

    interface_ids = []
    interfaces = data.dig('response', 0, 'interfaces')
    return [] unless interfaces.is_a?(Array)

    interfaces.each do |interface|
      vlan = interface['vlan']
      next if vlan.nil?

      fabric = vlan['fabric'].to_s.gsub("fabric-", "")
      if fabric.to_i.to_s == fabric
        interface_ids << interface['id']
      end
    end

    interface_ids
  end
end
