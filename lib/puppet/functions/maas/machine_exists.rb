require "uri"
require "net/http"
require "resolv"

Puppet::Functions.create_function(:'maas::machine_exists') do
  dispatch :machine_exists do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :machine_name
    param 'Boolean', :module_debug
  end

  def machine_exists(server, consumer_token, auth_token, auth_signature, machine_name, module_debug)
    addr = Resolv.getaddress(server)
    url = URI("http://#{addr}:8180/plugins/maas/machine/id?host=#{machine_name}")
    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30, '0')
    request = Net::HTTP::Get.new(url)

    begin
      response = http.request(request)
      data = JSON.parse(response.read_body)
      result = data.dig('response', 0, 'machine') == machine_name
      Puppet.info("maas::machine_exists: match found for #{machine_name}") if result && module_debug
      return result
    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e}"
      return false
    end
  end
end
