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
  Optional[Boolean] $module_debug = false,
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
  if $module_debug {
    info("maas: server = ${server}")
  }
  
  $key = $maas_consumer_key ? {
    undef   => $::maas::maas_consumer_key,
    ""      => $::maas::maas_consumer_key,
    default => $maas_consumer_key,
  }
  if $key == undef or $key == "" {
    err('maas_consumer_key is required and must be set at the class level or in the host parameters')
  }
  if $module_debug {
    info("maas: key = ${key}")
  }

  $token = $maas_token_key ? {
    undef   => $::maas::maas_token_key,
    ""      => $::maas::maas_token_key,
    default => $maas_token_key,
  }
  if $token == undef or $token == "" {
    err('maas_token_key is required and must be set at the class level or in the host parameters')
  }
  if $module_debug {
    info("maas: token = ${token}")
  }

  $secret = $maas_token_secret ? {
    undef   => $::maas::maas_token_secret,
    ""      => $::maas::maas_token_secret,
    default => $maas_token_secret,
  }
  if $secret == undef or $ksecretey == "" {
    err('maas_token_secret is required and must be set at the class level or in the host parameters')
  }
  if $module_debug {
    info("maas: secret = ${secret}")
  }
  
  case $ensure {
    # Make sure system is enlisted in some state
    'new', 'created', 'ready', 'present', 'commissioned', 'deployed': {
      if $module_debug {
        info("maas: creating machine. ensure = ${ensure}")
      }
      
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
        if $module_debug {
          info("maas: creating machine. name = ${machine_name}, domain = ${machine_domain}, mac = ${machine_mac}, commission = ${commission}, power = ${power_type}, params = ${power_parameters}")
        }
        
        # Create the machine
        $result = maas::machine_create($server, $key, $token, $secret, $machine_name, $machine_domain, $machine_architecture, $machine_mac, $machine_description, $commission, false, $power_type, $power_parameters)
        if $module_debug {
          info("maas: creating machine result = ${result}")
        }
      }

      # Get the machines status
      $status = maas::machine_get_status($server, $key, $token, $secret, $machine_name)
      if $module_debug {
        info("maas: status = ${status}")
      }

      # Set the pool
      if $machine_pool != '' {

        # Get the system id
        $pool_system_id = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)
        if $module_debug {
          info("maas: pool_system_id: ${pool_system_id}")
        }
        
        if $pool_system_id != undef {
          if maas::machine_get_pool($server, $key, $token, $secret, $pool_system_id) != $machine_pool {
            maas::machine_set_pool($server, $key, $token, $secret, $pool_system_id, $machine_pool)
            if $module_debug {
             info("maas: set machine pool = ${machine_pool}")
            }
          }
        }
      }

      # NEW = 0
      # READY = 4
      # BROKEN = 8
      # ALLOCATED = 10
      # If a default fabric is set then make sure all unassigned interfaces are put on the default fabric
      if $status == 0 or $status == 4 or $status == 8 or $status == 10 and $::maas::maas_default_fabric != '' {
        if $module_debug {
         info("maas: machine is in status = ${status} and default fabric is configured to be set to ${::maas::maas_default_fabric}")
        }
        
        $int_system_id = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)

        $unassigned_interfaces = maas::machine_get_unidentified_interfaces($server, $key, $token, $secret, $int_system_id)
        if $module_debug {
          info("maas: machine has the following unassigned interfaces ${unassigned_interfaces}")
        }
        
        $vlan_id = maas::fabric_get_default_vlan($server, $key, $token, $secret, $::maas::maas_default_fabric)
        $unassigned_interfaces.each | $idx, $interface_id | {
          maas::interface_update_fabric($server, $key, $token, $secret, $int_system_id, $interface_id, $vlan_id)
          if $module_debug {
            info("maas: updated fabric on ${int_system_id} interface ${interface_id} to ${vlan_id}")
          }
        }
      }

      # If it should be in a commissioned state then ensure it has been commissioned
      if $ensure == 'ready' or $ensure == 'present' or $ensure == 'commissioned' or $ensure == 'deployed' {
        # Commission if the system is in the new state
        if $status == 0 {
          if $module_debug {
            info("maas: status is currently 'new' and should be ${ensure}")
          }
          $commission_system_id = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)
          if $commission_system_id != undef {
            if $module_debug {
              info("maas: commissioning system ${commission_system_id}")
            }
            $commission_result = maas::machine_commission($server, $key, $token, $secret, $commission_system_id)
            if $module_debug {
              info("maas: commission result = ${commission_result}")
            }
          }
        }
      }

      # If the system should be deployed deploy it once it is in the ready state
      if $ensure == 'deployed' {
        if $status == 4 {
          if $module_debug {
            info("maas: status is currently 'ready' and should be ${ensure}")
          }
          $system_to_deploy = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)
          if $system_to_deploy != undef {
            if $module_debug {
              info("maas: deploying system ${system_to_deploy}")
            }
            $deploy_result = maas::machine_deploy($server, $key, $token, $secret, $system_to_deploy, $user_data_b64)
            if $module_debug {
              info("maas: deploy result = ${deploy_result}")
            }
          }
        }
      }
    }

    'absent': {
      if maas::machine_exists() {
        if $module_debug {
          info("maas: removing machine")
        }
        $result = maas::machine_delete()
      }
    }

    'register-deployed': {
      if !maas::machine_exists($server, $key, $token, $secret, $machine_name) {
        # Create the machine
        if $module_debug {
          info("maas: machine ${machine_name} doesn't exist but has been requested to be added in the deployed state")
        }
        $result = maas::machine_create($server, $key, $token, $secret, $machine_name, $machine_domain, $machine_architecture, $machine_mac, $machine_description, false, true, $power_type, $power_parameters)
        if $module_debug {
          info("maas: ${machine_name} create result = ${result}")
        }
        
        # Set the pool
        if $machine_pool != '' {

          # Get the system id
          $pool_system_id = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)

          if $pool_system_id != undef {
            if maas::machine_get_pool($server, $key, $token, $secret, $pool_system_id) != $machine_pool {
              if $module_debug {
                info("maas: setting pool for ${pool_system_id} to ${machine_pool}")
              }
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
