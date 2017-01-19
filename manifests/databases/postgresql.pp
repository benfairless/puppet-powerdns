# powerdns::databases::postgresql
#
# Manages pdns PostgreSQL backend
#
class powerdns::databases::postgresql (

  $ensure = present,
  $config = undef

) {

  include ::stdlib
  include ::powerdns::repository


  # Static variables
  ##############################################################################

  $dependencies = ['postgresql']
  $packages     = ['pdns-backend-postgresql']
  $sql_file     = '/etc/pdns/postgresql.sql'
  $sql_dir      = dirname($sql_file)
  $validation   = "SELECT table_name FROM information_schema.tables WHERE table_name='records';"


  # Input validation
  ##############################################################################

  validate_hash($config)
  unless has_key($config, 'host')
     and has_key($config, 'port')
     and has_key($config, 'user')
     and has_key($config, 'password')
     and has_key($config, 'database') {
    fail('The config parameter defined for powerdns::databases::postgresql is invalid')
  }


  # Apply actions
  ##############################################################################

  if $ensure == 'present' {

    ensure_packages($dependencies, { ensure => present })
    ensure_resource('file', $sql_dir, { ensure => directory })

    # Install sqlite backend packages
    package { $packages :
      ensure  => present,
      require => Class['powerdns::repository']
    }

    # Manage SQL script for populating database schema
    file { $sql_file :
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source => 'puppet:///modules/powerdns/postgresql.sql',
      require => File[$sql_dir]
    }

    # Create database
    $db_cmd = "/usr/bin/psql postgresql://${config['user']}@${config['host']}:${config['port']}/${config['database']}"
    exec { 'db-creation' :
        command     => "${db_cmd} -v ON_ERROR_STOP=1 -f ${sql_file}",
        environment => "PGPASSWORD=${config['password']}",
        unless      => "${db_cmd} -c \"${validation}\" | /usr/bin/grep 'records'",
        require     => [Package[$dependencies], File[$sql_file]]
    }

  } else {

    # Remove database dependencies
    # NOTE: No data within the database is harmed.
    package { $packages : ensure => absent }
    file { $sql_file : ensure => absent}

  }

}
