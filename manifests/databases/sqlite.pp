# powerdns::databases::sqlite
#
# Manages pdns SQLite backend
#
class powerdns::databases::sqlite (

  $ensure = present,
  $path   = undef,
  $user   = 'pdns',

) {

  include ::stdlib
  include ::powerdns::repository


  # Static variables
  ##############################################################################

  $dependencies = ['sqlite']
  $packages     = ['pdns-backend-sqlite']
  $sql_file     = '/etc/pdns/sqlite.sql'
  $sql_dir      = dirname($sql_file)


  # Input validation
  ##############################################################################

  validate_string($user)

  # Fail is path is not a path
  unless is_absolute_path($path) {
    fail('The path parameter defined for powerdns::databases::sqlite must be an absolute path')
  }


  # Apply actions
  ##############################################################################

  if $ensure == 'present' {

    $db_dir = dirname($path)
    ensure_packages($dependencies, { ensure => present })
    ensure_resource('file', [$sql_dir, $db_dir], { ensure => directory })

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
      source => 'puppet:///modules/powerdns/sqlite.sql',
      require => File[$sql_dir]
    }

    # Create database
    exec { 'db-creation' :
      command => "/usr/bin/sqlite3 -init ${sql_file} ${path}",
      user    => $owner,
      creates => $path,
      require => [Package[$dependencies], File[$sql_file], File[$db_dir]]
    }

  } else {

    # Remove database dependencies
    # NOTE: No data within the database is harmed.
    package { $packages : ensure => absent }
    file { $sql_file : ensure => absent}

  }

}
