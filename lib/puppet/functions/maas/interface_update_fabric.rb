# # frozen_string_literal: true
# require "uri"
# require "net/http"
#
# Puppet::Functions.create_function(:'maas::interface_update_fabric') do
#   dispatch :interface_update_fabric do
#     param 'String',  :server
#     param 'String',  :consumer_token
#     param 'String',  :auth_token
#     param 'String',  :auth_signature
#     param 'String',  :system_id
#     param 'Integer', :interface_id
#     param 'Integer', :vlan_id
#   end
#   def interface_update_fabric(server, consumer_token, auth_token, auth_signature, system_id, interface_id, vlan_id)
#     url = URI("http://#{server}:5240/MAAS/api/2.0/nodes/#{system_id}/interfaces/#{interface_id}/")
#
#     http = Net::HTTP.new(url.host, url.port)
#     nonce = rand(10 ** 30).to_s.rjust(30,'0')
#     request = Net::HTTP::Put.new(url)
#     request["Authorization"] = "OAuth oauth_consumer_key=\"#{consumer_token}\",oauth_token=\"#{auth_token}\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26#{auth_signature}\""
#     request["Content-Type"] = "application/json"
#     body = {
#       "vlan": vlan_id
#     }
#     request.body = JSON.dump(body)
#     response = http.request(request)
#     return response
#   end
# end
