# ::powerdns::server::recursor
#
# Manages pdns-recursor installation
#
class powerdns::server::recursor (

  $ensure  = present,
  $address = '127.0.0.1',
  $port    = 1053

) {

  include ::stdlib
  include ::powerdns::repository


  # Static variables
  ##############################################################################

  $dependencies = ['bind-utils']
  $packages     = ['pdns-recursor']
  $user         = 'pdns-recursor'
  $group        = 'pdns-recursor'
  $service      = 'pdns-recursor'
  $config       = '/etc/pdns-recursor/recursor.conf'


  # Input validation
  ##############################################################################

  validate_string($address)
  validate_integer($port)


  # Applied actions
  ##############################################################################

  if $ensure == 'present' {

    ensure_packages($dependencies, { ensure => present })

    # Install recursor packages
    package { $packages :
      ensure  => present,
      require => Class['powerdns::repository'],
      notify  => Service[$service]
    }

    # Manage configuration file
    file { $config :
      ensure  => present,
      owner   => $user,
      group   => $group,
      mode    => '0644',
      content => template('powerdns/recursor.conf.erb'),
      require => Package[$packages],
      notify  => Service[$service]
    }

    # Manage recursor service
    service { $service :
      ensure    => running,
      enable    => true,
      require   => [Package[$packages], File[$config]],
      subscribe => [Package[$packages], File[$config]]
    }

  } else {

    # Remove recursor packages
    package { $packages : ensure => absent }

    # Stop recursor service
    service { $service :
      ensure => stopped,
      enable => false
    }

  }
}
