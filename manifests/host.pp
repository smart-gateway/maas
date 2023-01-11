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
  String            $power_type = 'manual',
  Hash              $power_parameters = {},
) {

  # Ensure Values
  # new (new/created)
  # ready (ready/commissioned/present)
  # deployed (deployed)
  # absent (absent/removed)

  case $ensure {
    'present': {
      if !maas::machine_exists() {

      }
    }

    'absent': {
      if maas::machine_exists() {

      }
    }

    default: {
      err("invalid ensure value ${ensure} specified")
    }
  }
}
