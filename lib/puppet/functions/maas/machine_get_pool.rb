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
    url = URI("http://#{server}:8180/plugins/maas/machine/pool?id=#{system_id}")

    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30, '0')
    request = Net::HTTP::Get.new(url)

    begin
      response = http.request(request)
      data = JSON.parse(response.read_body)
      return data.dig('response', 0, 'pool', 'name')
    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e}"
    end

    Puppet.warning("maas::machine_get_pool: failed to get pool name for system ID '#{system_id}'")
    nil
  end
end
