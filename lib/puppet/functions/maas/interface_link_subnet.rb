# frozen_string_literal: true
require "uri"
require "net/http"
require "json"
require "ipaddr"

Puppet::Functions.create_function(:'maas::interface_link_subnet') do
  dispatch :interface_link_subnet do
    param 'String',  :server
    param 'String',  :consumer_token
    param 'String',  :auth_token
    param 'String',  :auth_signature
    param 'String',  :system_id
    param 'Integer', :interface_id
    param 'String',  :ip_with_cidr   # e.g., "10.21.27.29/21"
    optional_param 'Boolean', :default_gateway
    optional_param 'Boolean', :force
  end

  def interface_link_subnet(server, consumer_token, auth_token, auth_signature, system_id, interface_id, ip_with_cidr, default_gateway = false, force = false)
    ip, prefix = ip_with_cidr.split('/')
    subnet = IPAddr.new("#{ip}/#{prefix}")
    subnet_base = subnet.mask(prefix.to_i).to_s
    subnet_cidr = "#{subnet_base}/#{prefix}"
    force = true

    url = URI("http://#{server}:5240/MAAS/api/2.0/nodes/#{system_id}/interfaces/#{interface_id}/?op=link_subnet")
    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30,'0')

    request = Net::HTTP::Post.new(url)
    request["Authorization"] =
      "OAuth oauth_consumer_key=\"#{consumer_token}\"," \
        "oauth_token=\"#{auth_token}\"," \
        "oauth_signature_method=\"PLAINTEXT\"," \
        "oauth_timestamp=\"#{Time.now.to_i}\"," \
        "oauth_nonce=\"#{nonce}\"," \
        "oauth_version=\"1.0\"," \
        "oauth_signature=\"%26#{auth_signature}\""

    form = {
      "subnet" => subnet_cidr,
      "mode" => "STATIC",
      "ip_address" => ip,
    }
    form["default_gateway"] = "true" if default_gateway
    form["force"] = "true" if force

    request.set_form_data(form)
    response = http.request(request)
    response.body
  end
end