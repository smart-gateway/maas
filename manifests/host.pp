# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   maas::host { 'namevar': }
define maas::host (
  String            $ensure = present,
  String            $machine_name,
  String            $machine_mac,
  String            $machine_description = '',
  String            $machine_domain = '',
  String            $machine_architecture = 'amd64',
  String            $machine_owner = '',
  Optional[String]  $maas_server = undef,
  Optional[String]  $maas_consumer_key = undef,
  Optional[String]  $maas_token_key = undef,
  Optional[String]  $maas_token_secret = undef,
  Optional[String]  $power_type = 'manual',
  Optional[Hash]    $power_parameters = {},
  Optional[String]  $user_data_b64 = '',
  Optional[String]  $machine_zone = '',
  Optional[String]  $machine_pool = '',
) {

  # Ensure Values
  # new (new/created)
  # ready (ready/commissioned/present)
  # deployed (deployed)
  # absent (absent/removed)
  $server = $maas_server ? {
    undef   => $::maas::maas_server,
    ""      => $::maas::maas_server,
    default => $maas_server,
  }

  $key = $maas_consumer_key ? {
    undef   => $::maas::maas_consumer_key,
    ""      => $::maas::maas_consumer_key,
    default => $maas_consumer_key,
  }
  if $key == undef or $key == "" {
    err('maas_consumer_key is required and must be set at the class level or in the host parameters')
  }

  $token = $maas_token_key ? {
    undef   => $::maas::maas_token_key,
    ""      => $::maas::maas_token_key,
    default => $maas_token_key,
  }
  if $key == undef or $key == "" {
    err('maas_token_key is required and must be set at the class level or in the host parameters')
  }

  $secret = $maas_token_secret ? {
    undef   => $::maas::maas_token_secret,
    ""      => $::maas::maas_token_secret,
    default => $maas_token_secret,
  }
  if $key == undef or $key == "" {
    err('maas_token_secret is required and must be set at the class level or in the host parameters')
  }

  case $ensure {
    # Make sure system is enlisted in some state
    'new', 'created', 'ready', 'present', 'commissioned', 'deployed': {

      # If system doesn't exist yet then create it
      if !maas::machine_exists($server, $key, $token, $secret, $machine_name) {
        # Set a variable that says if we should commission the newly added system or not
        $commission = $ensure ? {
          'ready'        => true,
          'present'      => true,
          'commissioned' => true,
          'deployed'     => true,
          default        => false,
        }
        # Create the machine
        $result = maas::machine_create($server, $key, $token, $secret, $machine_name, $machine_domain, $machine_architecture, $machine_mac, $machine_description, $commission, false, $power_type, $power_parameters)
      }

      # Get the machines status
      $status = maas::machine_get_status($server, $key, $token, $secret, $machine_name)

      # Set the pool
      if $machine_pool != '' {

        # Get the system id
        $pool_system_id = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)

        if $pool_system_id != undef {
          if maas::machine_get_pool($server, $key, $token, $secret, $pool_system_id) != $machine_pool {
            maas::machine_set_pool($server, $key, $token, $secret, $pool_system_id, $machine_pool)
          }
        }
      }

      # NEW = 0
      # READY = 4
      # BROKEN = 8
      # ALLOCATED = 10
      # If a default fabric is set then make sure all unassigned interfaces are put on the default fabric
      if $status == 0 or $status == 4 or $status == 8 or $status == 10 and $::maas::maas_default_fabric != '' {
        $int_system_id = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)

        $unassigned_interfaces = maas::machine_get_unidentified_interfaces($server, $key, $token, $secret, $int_system_id)
        $vlan_id = maas::fabric_get_default_vlan($server, $key, $token, $secret, $::maas::maas_default_fabric)
        $unassigned_interfaces.each | $idx, $interface_id | {
          maas::interface_update_fabric($server, $key, $token, $secret, $int_system_id, $interface_id, $vlan_id)
        }
      }

      # If it should be in a commissioned state then ensure it has been commissioned
      if $ensure == 'ready' or $ensure == 'present' or $ensure == 'commissioned' or $ensure == 'deployed' {
        # Commission if the system is in the new state
        if $status == 0 {
          $commission_system_id = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)
          if $commission_system_id != Undef {
            $commission_result = maas::machine_commission($server, $key, $token, $secret, $commission_system_id)
          }
        }
      }

      # If the system should be deployed deploy it once it is in the ready state
      if $ensure == 'deployed' {
        if $status == 4 {
          $system_to_deploy = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)
          if $system_to_deploy != Undef {
            $deploy_result = maas::machine_deploy($server, $key, $token, $secret, $system_to_deploy, $user_data_b64)
          }
        }
      }
    }

    'absent': {
      if maas::machine_exists() {
        $result = maas::machine_delete()
        notify { "result: ${result}": }
      }
    }

    'register-deployed': {
      if !maas::machine_exists($server, $key, $token, $secret, $machine_name) {
        # Create the machine
        notify { "creating ${machine_name}": }
        $result = maas::machine_create($server, $key, $token, $secret, $machine_name, $machine_domain, $machine_architecture, $machine_mac, $machine_description, false, true, $power_type, $power_parameters)
        notify { "${machine_name} creation results: ${result}": }
        # Set the pool
        if $machine_pool != '' {

          # Get the system id
          $pool_system_id = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)

          if $pool_system_id != Undef {
            if maas::machine_get_pool($server, $key, $token, $secret, $pool_system_id) != $machine_pool {
              maas::machine_set_pool($server, $key, $token, $secret, $pool_system_id, $machine_pool)
            }
          }

        }
      }
    }
    default: {
      err("invalid ensure value ${ensure} specified")
    }
  }
}
