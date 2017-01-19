# ::powerdns::repository
#
# Manages PowerDNS repository
#
class powerdns::repository (

  $ensure = present

){

  include ::stdlib

  # Static Variables
  ##############################################################################

  $dependencies = ['epel-release', 'yum-plugin-priorities']
  $repo_path = '/etc/yum.repos.d/powerdns.repo'


  # Applied actions
  ##############################################################################

  if $ensure == 'present' {

    ensure_packages($dependencies, { ensure => present })

    # Add PowerDNS YUM repository
    file { $repo_path :
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source => 'puppet:///modules/powerdns/powerdns.repo'
    }

  } else {

    # Remove PowerDNS YUM repository
    file { $repo_path :
      ensure => absent
    }

  }
}
