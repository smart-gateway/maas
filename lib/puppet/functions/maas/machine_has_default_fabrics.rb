Puppet::Functions.create_function(:'maas::machine_has_default_fabrics') do
  dispatch :machine_has_default_fabrics do
    param 'String', :server
    param 'String', :consumer_token
    param 'String', :auth_token
    param 'String', :auth_signature
    param 'String', :system_id
  end

  def machine_has_default_fabrics(server, consumer_token, auth_token, auth_signature, system_id)
    interfaces = call_function('maas::machine_get_unidentified_interfaces', server, consumer_token, auth_token, auth_signature, system_id)
    return interfaces.any?
  end
end