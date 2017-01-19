#
class powerdns::server (

  $ensure      = present,
  $password    = 'password',
  $api_port    = 8081,
  $postgresql  = undef,
  $sqlite_path = undef

) {

  include ::stdlib


  # Static variables
  ##############################################################################

  $recursor = {
    host => '127.0.0.1',
    port => 1053
  }


  # Input validation
  ##############################################################################

  validate_string($password)
  validate_integer($api_port)


  # Apply actions
  ##############################################################################

  if $ensure == 'present' {

    class { powerdns::server::authoritive :
      ensure      => present,
      recursor    => $recursor,
      password    => $password,
      api_port    => $api_port,
      postgresql  => $postgresql,
      sqlite_path => $sqlite_path
    }

    class { powerdns::server::recursor :
      ensure => present,
      address => $recursor['host'],
      port    => $recursor['port']
    }

  } else {

    class { powerdns::server::authoritive : ensure => absent }
    class { powerdns::server::recursor : ensure => absent }

  }

}
