# ::powerdns::server::authoritive
#
# Manages pdns installation
#
class powerdns::server::authoritive (

  $ensure        = present,
  $password      = 'password',
  $port          = 53,
  $api_port      = 8081,
  $recursor      = undef,
  $postgresql    = undef,
  $sqlite_path   = undef

) {

  include ::stdlib
  include ::powerdns::repository


  # Static variables
  #################################################################

  $dependencies        = ['bind-utils']
  $packages            = ['pdns', 'pdns-tools']
  $user                = 'pdns'
  $group               = 'pdns'
  $service             = 'pdns'
  $config              = '/etc/pdns/pdns.conf'
  $default_sqlite_path = '/var/lib/pdns/pdns.db'


  # Input validation
  #################################################################

  validate_string($password)
  validate_integer($port)
  validate_integer($api_port)

  # Validate recursor hash
  if $recursor {
    validate_hash($recursor)
    unless has_key($recursor, 'host')
       and has_key($recursor, 'port') {
      fail('The recursor parameter defined for powerdns::server::authoritive is invalid')
    }
  }

  # Validate postgresql hash
  if $postgresql {
    validate_hash($postgresql)
    unless has_key($postgresql, 'host')
       and has_key($postgresql, 'port')
       and has_key($postgresql, 'user')
       and has_key($postgresql, 'password')
       and has_key($postgresql, 'database') {
      fail('The postgresql parameter defined for powerdns::server::authoritive is invalid')
    }
    # Ensure user is notified of hierarchy
    if $sqlite_path {
      warning('Both the postgresql and sqlite_path parameters have been defined for powerdns::server::authoritive. The postgresql parameter will override sqlite_path')
    }
  }

  # Validate sqlite_path
  if $sqlite_path {
    # Fail is sqlite_path is not a path
    unless is_absolute_path($sqlite_path) {
      fail('The sqlite_path parameter defined for powerdns::server::authoritive must be an absolute path')
    }
    # Use specified sqlite path
    $defined_sqlite_path = $sqlite_path
  } else {
    # Fall back to default sqlite path
    $defined_sqlite_path = $default_sqlite_path
  }


  # Applied actions
  #################################################################

  if $ensure == 'present' {

    ensure_packages($dependencies, { ensure => present })

    # Install pdns packages
    package { $packages :
      ensure  => present,
      require => Class['powerdns::repository']
    }

    # Manage configuration file
    file { $config :
      ensure  => present,
      owner   => $user,
      group   => $group,
      mode    => '0644',
      content => template('powerdns/pdns.conf.erb'),
      require => Package[$packages],
      notify  => Service[$service]
    }

    if $postgresql {

      # Manage PostgreSQL database
      class { powerdns::databases::postgresql :
        ensure => present,
        config => $postgresql
      }

      # Ensure pdns service does not start until database is configured
      $service_dependencies = [
        Package[$packages],
        File[$config],
        Class['powerdns::databases::postgresql']
      ]

    } else {

      # Manage SQLite3 database
      class { powerdns::databases::sqlite :
        ensure => present,
        path   => $defined_sqlite_path,
        user   => $user,
      }

      $service_dependencies = [
        Package[$packages],
        File[$config],
        Class['powerdns::databases::sqlite']
      ]

    }

    # Manage pdns service
    service { $service :
      ensure    => running,
      enable    => true,
      require   => $service_dependencies,
      subscribe => File[$config]
    }

  } else {

    # Remove pdns packages
    package { $packages : ensure => absent }

    # Stop pdns service
    service { $service :
      ensure => stopped,
      enable => false
    }

    # Remove database dependencies
    # NOTE: To prevent unwanted data deletion, these classes will not remove actual data
    if $postgresql {
      class { powerdns::databases::postgres : ensure => absent }
    } else {
      class { powerdns::databases::sqlite : ensure => absent }
    }

  }
}
