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
    url = URI("http://#{server}:8180/plugins/maas/machine/id?host=#{machine_name}")
    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30, '0')
    request = Net::HTTP::Get.new(url)

    begin
      data = JSON.parse(response = http.request(request).read_body)
      return data['response'][0]['id'] if data['response'] && data['response'][0]
    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e}"
    end

    # Optional: warn if not found
    Puppet.warning("maas::machine_get_system_id: failed to get system ID for '#{machine_name}'")
    return nil
  end
end
