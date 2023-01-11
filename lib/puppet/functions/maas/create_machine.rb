# frozen_string_literal: true
require "uri"
require "net/http"

Puppet::Functions.create_function(:'maas::create_machine') do

  def create_machine()
    url = URI("http://maas.edge.lan:5240/MAAS/api/2.0/machines/")

    http = Net::HTTP.new(url.host, url.port);
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"wzKJH2WQJQ2QVYWjqZ\",oauth_token=\"SLFU2E9EqjMwUmJY4V\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"HH4LUSureA3\",oauth_version=\"1.0\",oauth_signature=\"%26XRnrfpxugwyFayLPu8Aqya4jMDxwMCSv\""
    request["Content-Type"] = "application/json"
    request.body = JSON.dump({
                               "architecture": "amd64",
                               "min_hwe_kernel": "",
                               "mac_addresses": "52:54:00:e0:9e:51",
                               "hostname": "vm-example-01",
                               "description": "Puppet deployed and controlled VM",
                               "power_type": "virsh",
                               "power_parameters_power_address": "qemu+ssh://intel@<node>.maas.edge.lan/system",
                               "power_parameters_power_id": "vm-example-01",
                               "commission": true,
                               "testing_scripts": "none",
                               "domain": "lenovo.edge.lan"
                             })
    response = http.request(request)
    return response.read_body
  end
end

