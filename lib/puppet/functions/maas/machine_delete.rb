require "uri"
require "net/http"

Puppet::Functions.create_function(:'maas::delete_machine') do

  dispatch :delete_machine do

  end
  def delete_machine()
    url = URI("http://#{server}:5240/MAAS/api/2.0/machines/")

    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30,'0')
    request = Net::HTTP::Delete.new(url)
    request["Authorization"] = "OAuth oauth_consumer_key=\"wzKJH2WQJQ2QVYWjqZ\",oauth_token=\"SLFU2E9EqjMwUmJY4V\",oauth_signature_method=\"PLAINTEXT\",oauth_timestamp=\"#{Time.now.to_i}\",oauth_nonce=\"#{nonce}\",oauth_version=\"1.0\",oauth_signature=\"%26XRnrfpxugwyFayLPu8Aqya4jMDxwMCSv\""
    request["Content-Type"] = "application/json"
    request.body = JSON.dump({
                               "architecture": "amd64",
                               "min_hwe_kernel": "",
                               "mac_addresses": "52:54:00:e0:9e:51",
                               "hostname": "vm-custom-01",
                               "description": "Puppet deployed and controlled VM",
                               "power_type": "virsh",
                               "power_parameters_power_address": "qemu+ssh://intel@node02.maas.edge.lan/system",
                               "power_parameters_power_id": "vm-custom-01",
                               "commission": true,
                               "testing_scripts": "none",
                               "domain": "lenovo.edge.lan"
                             })
    response = http.request(request)
    return response.read_body
  end
end
