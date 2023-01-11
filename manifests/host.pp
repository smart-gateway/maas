# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   maas::host { 'namevar': }
define maas::host (
  String            $ensure = present,
  String            $maas_server = 'localhost',
  Sensitive[String] $maas_consumer_key,
  Sensitive[String] $maas_token_key,
  Sensitive[String] $maas_token_secret,
  String            $machine_name,
  String            $machine_mac,
  String            $machine_description = '',
  String            $machine_domain = '',
  String            $machine_architecture = 'amd64',
  Optional[String]  $power_type = 'manual',
  Optional[Hash]    $power_parameters = {},
  Optional[String]  $user_data_b64 = '',
) {

  # Ensure Values
  # new (new/created)
  # ready (ready/commissioned/present)
  # deployed (deployed)
  # absent (absent/removed)

  case $ensure {
    'present', 'deployed': {
      if !maas::machine_exists($maas_server, $maas_consumer_key.unwrap, $maas_token_key.unwrap, $maas_token_secret.unwrap, $machine_name) {
        $result = maas::machine_create($maas_server, $maas_consumer_key.unwrap, $maas_token_key.unwrap, $maas_token_secret.unwrap, $machine_name, $machine_domain, $machine_architecture, $machine_mac, $machine_description, $power_type, $power_parameters)
      }

      if $ensure == 'deployed' {
        $status = maas::machine_get_status($maas_server, $maas_consumer_key.unwrap, $maas_token_key.unwrap, $maas_token_secret.unwrap, $machine_name)
        if $status == 4 {
          $system_id = maas::machine_get_system_id($maas_server, $maas_consumer_key.unwrap, $maas_token_key.unwrap, $maas_token_secret.unwrap, $machine_name)
          if $system_id != Undef {
            $deploy_result = maas::machine_deploy($maas_server, $maas_consumer_key.unwrap, $maas_token_key.unwrap, $maas_token_secret.unwrap, $system_id, $user_data_b64)
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
