# frozen_string_literal: true
require "uri"
require "net/http"
require "securerandom"

Puppet::Functions.create_function(:'maas::machine_deploy') do
  dispatch :machine_deploy do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :system_id
    param 'String', :user_data_b64
  end

  def machine_deploy(server, consumer_token, auth_token, auth_signature, system_id, user_data_b64)
    url = URI("http://#{server}:5240/MAAS/api/2.0/machines/#{system_id}/?op=deploy")

    http = Net::HTTP.new(url.host, url.port)
    nonce = rand(10 ** 30).to_s.rjust(30, '0')

    boundary = "----RubyFormBoundary#{SecureRandom.hex(16)}"
    request = Net::HTTP::Post.new(url)
    request["Authorization"] =
      "OAuth oauth_consumer_key=\"#{consumer_token}\"," \
        "oauth_token=\"#{auth_token}\"," \
        "oauth_signature_method=\"PLAINTEXT\"," \
        "oauth_timestamp=\"#{Time.now.to_i}\"," \
        "oauth_nonce=\"#{nonce}\"," \
        "oauth_version=\"1.0\"," \
        "oauth_signature=\"%26#{auth_signature}\""
    request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"

    multipart_body = []
    multipart_body << "--#{boundary}"
    multipart_body << "Content-Disposition: form-data; name=\"enable_hw_sync\""
    multipart_body << ""
    multipart_body << "false"

    multipart_body << "--#{boundary}"
    multipart_body << "Content-Disposition: form-data; name=\"user_data\""
    multipart_body << ""
    multipart_body << user_data_b64

    multipart_body << "--#{boundary}--"
    multipart_body << ""

    request.body = multipart_body.join("\r\n")
    Puppet.send("warning", "deploy request body:\n#{request.body}")

    response = http.request(request)
    response.code == '200'
  end
end
