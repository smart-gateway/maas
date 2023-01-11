# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include maas
class maas (
  Optional[String] $maas_server = 'localhost',
  String           $maas_consumer_key,
  String           $maas_token_key,
  String           $maas_token_secret,
  Optional[String] $maas_default_fabric = '',
) {
  # Notes:
  #   1. A machine can be created with deployed = true which will skip commissioning and deployment and mark it as deployed.


  # TODO: Functions that need to be implemented
  # POST - /MAAS/api/2.0/machines/
  #   architecture=amd64
  #   mac_address=
  #   hostname=<vm_name>
  #   description=<vm_description>
  #   power_type=virsh
  #   power_parameters_power_address=qemu+ssh://intel@<node>.maas.edge.lan/system
  #   power_parameters_power_id=<vm_name>
  #   commission=true
  #   domain=
}
