# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   maas::host { 'namevar': }
define maas::host (
  String $maas_server = 'localhost',
  String $maas_api_base = '/MAAS/api/2.0/',
  Sensitive[String] $maas_consumer_key = '',
  Sensitive[String] $maas_token_key = '',
  Sensitive[String] $maas_token_secret = '',
) {
  # Test to see if I can even access the API
  $result = maas::get_machines()
  notify { "result: ${result}": }
}
