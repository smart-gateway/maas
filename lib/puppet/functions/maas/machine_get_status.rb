require "uri"
require "net/http"

# NEW = 0
# # Testing and other commissioning steps are taking place.
# COMMISSIONING = 1
# # The commissioning step failed.
# FAILED_COMMISSIONING = 2
# # The node can't be contacted.
# MISSING = 3
# # The node is in the general pool ready to be deployed.
# READY = 4
# # The node is ready for named deployment.
# RESERVED = 5
# # The node has booted into the operating system of its owner's choice
# # and is ready for use.
# DEPLOYED = 6
# # The node has been removed from service manually until an admin
# # overrides the retirement.
# RETIRED = 7
# # The node is broken: a step in the node lifecyle failed.
# # More details can be found in the node's event log.
# BROKEN = 8
# # The node is being installed.
# DEPLOYING = 9
# # The node has been allocated to a user and is ready for deployment.
# ALLOCATED = 10
# # The deployment of the node failed.
# FAILED_DEPLOYMENT = 11
# # The node is powering down after a release request.
# RELEASING = 12
# # The releasing of the node failed.
# FAILED_RELEASING = 13
# # The node is erasing its disks.
# DISK_ERASING = 14
# # The node failed to erase its disks.
# FAILED_DISK_ERASING = 15
# # The node is in rescue mode.
# RESCUE_MODE = 16
# # The node is entering rescue mode.
# ENTERING_RESCUE_MODE = 17
# # The node failed to enter rescue mode.
# FAILED_ENTERING_RESCUE_MODE = 18
# # The node is exiting rescue mode.
# EXITING_RESCUE_MODE = 19
# # The node failed to exit rescue mode.
# FAILED_EXITING_RESCUE_MODE = 20
# # Running tests on Node
# TESTING = 21
# # Testing has failed
# FAILED_TESTING = 22

Puppet::Functions.create_function(:'maas::machine_get_status') do
  dispatch :machine_get_status do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :machine_name
  end
  def machine_get_status(server, consumer_token, auth_token, auth_signature, machine_name)
    #url = URI("http://#{server}:5240/MAAS/api/2.0/machines/?hostname=#{machine_name}")
    url = URI("http://#{server}:8180/plugins/maas/machine/status?host=#{machine_name}")
    http = Net::HTTP.new(url.host, url.port);
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Get.new(url)
    #request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
    response = http.request(request)
    #data = JSON.parse(response.read_body)

    begin
      data = JSON.parse(response.read_body)
      return data['response'][0]['status'] if data['response'] && data['response'][0]
    rescue JSON::ParserError => e
      puts "Error parsing JSON: #{e}"
      return nil
    end
      #data.each do |host|
      #if host['hostname'] == machine_name
      #  return host['status']
      #end
      #end

      #    return nil
  end
end