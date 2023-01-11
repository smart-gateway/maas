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
  Optional[String]  $maas_server = undef,
  Optional[String]  $maas_consumer_key = undef,
  Optional[String]  $maas_token_key = undef,
  Optional[String]  $maas_token_secret = undef,
  Optional[String]  $power_type = 'manual',
  Optional[Hash]    $power_parameters = {},
  Optional[String]  $user_data_b64 = '',
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
    'present', 'deployed': {
      if !maas::machine_exists($server, $key, $token, $secret, $machine_name) {
        $result = maas::machine_create($server, $key, $token, $secret, $machine_name, $machine_domain, $machine_architecture, $machine_mac, $machine_description, $power_type, $power_parameters)
      }

      if $ensure == 'deployed' {
        $status = maas::machine_get_status($server, $key, $token, $secret, $machine_name)
        if $status == 4 {
          $system_id = maas::machine_get_system_id($server, $key, $token, $secret, $machine_name)
          if $system_id != Undef {
            $deploy_result = maas::machine_deploy($server, $key, $token, $secret, $system_id, $user_data_b64)
          }
        } elsif $status == 6 or $status == 9 {
          # System is already deploying or deployed
        } else {
          notify { "${machine_name} unable to deploy as status is not in 'ready'...status = ${status}": }
        }
      }
    }

    'absent': {
      if maas::machine_exists() {
        $result = maas::machine_delete()
        notify { "result: ${result}": }
      }
    }

    default: {
      err("invalid ensure value ${ensure} specified")
    }
  }
}
