class powerdns::test (
  $test = undef
) {

  if $test == 'absent' {
    $classes = [
      'powerdns::repository',
      'powerdns::server::authoritive',
      'powerdns::server::recursor'
      ]
    class { $classes : ensure => absent }
  } elsif $test == 'repository' {
    class { powerdns::repository : ensure => present }
  } elsif $test == 'recursor' {
    class { powerdns::server::recursor : ensure => present }
  } elsif $test == 'auth' {
    class { powerdns::server::authoritive : ensure => present }
  } elsif $test == 'auth-sqlite' {
    class { powerdns::server::authoritive :
      ensure => present,
      # sqlite_path => 'shouldfail'
      sqlite_path => '/this/shouldpass'
    }
  } elsif $test == 'auth-postgresql' {
    class { powerdns::server::authoritive :
      ensure => present,
      postgresql => {
        host => 'd',
        port => 'd',
        user => 'd',
        password => 'd',
        database => 'd'
      },
      # sqlite_path => '/shouldwarn'
    }
  } elsif $test == 'auth-recursor' {
    class { powerdns::server::authoritive :
      ensure => present,
      recursor => {
        host => 'd',
        port => 'd',
      }
    }
  } elsif $test == 'sqlite' {
    class { powerdns::server::authoritive : ensure => absent}
    class { powerdns::databases::sqlite :
      ensure => present,
      path => '/test'
    }
  }

}
