require "uri"
require "net/http"
require 'resolv'

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
    #url = URI("http://#{addr}:5240/MAAS/api/2.0/machines/?hostname=#{machine_name}")
    url = URI("http://#{addr}:8080/plugins/maas/machine/id?host=#{machine_name}")
    http = Net::HTTP.new(url.host, url.port);
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Get.new(url)
    #request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    response = http.request(request)

    begin
      data = JSON.parse(response.read_body)
      return data['machine'] == machine_name
    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e}"
      return false
    end

    return false

    # data = JSON.parse(response.read_body)
    # data.each do |host|
    #   if host['hostname'] == machine_name
    #     Puppet.send("info", "found host: #{host}") if module_debug
    #     return true
    #   end
    # end
    # return false
    # url = URI("http://#{server}:5240/MAAS/api/2.0/machines/")
    # http = Net::HTTP.new(url.host, url.port);
    # nonce = rand(10 ** 30).to_s.rjust(30,'0')
    # request = Net::HTTP::Get.new(url)
    # request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    # response = http.request(request)
    # data = JSON.parse(response.read_body)

    # data.each do |host|
    #   if host['hostname'] == machine_name
    #     return true
    #   end
    # end
    #
    # return false
  end
end