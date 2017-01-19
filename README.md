benfairless/powerdns
====================

This Puppet module manages [PowerDNS](https://powerdns.com/) installation and configuration. It supports authoritive and recursive name servers and can be backed by either a SQLite or PostgreSQL database.

---
## Usage

#### Quick install
```puppet
class { ::powerdns::server :
  ensure   => present,
  password => 'MDM5YW=mZmFi' # API password
}
```
The above snippet will install a fully configured PowerDNS Authoritive name server, a recursive name server for which to forward non-authoritive searches on to, the PowerDNS API, and a local SQLite3 backend.

For standalone installations this should be adequate for most use cases.

#### Quick install with PostgreSQL
```puppet
class { ::powerdns::server :
  ensure     => present,
  password   => 'MDM5YW=mZmFi', # API password
  postgresql => {
    host     => '127.0.0.1',    # Database host address
    port     => 5432,           # Database host port
    user     => 'pdns',         # Database user account
    password => 'xY2U%OWFhMjg', # Database password
    database => 'powerdns'      # Database logical name
  }
}
```
The above snippet will follow similar behaviour to the one displayed above under *Quick Install* but will use a PostgreSQL database instead of a local SQLite database.

This has the benefit of allowing multiple active authoritive name servers because the database does not need to sit on the same machine.

---
## Classes

#### powerdns::repository

Configures PowerDNS YUM repository

| Parameter | Values               | Description                    |
|-----------|----------------------|--------------------------------|
| `ensure`  | `present` / `absent` | Adds/removes repository in YUM |

#### powerdns::server

High-level class configuring both PowerDNS and PowerDNS Recursor together with sane options

| Parameter     | Default value | Description                                                    |
|---------------|---------------|----------------------------------------------------------------|
| `ensure`      | `present`     | Adds/removes PDNS & PDNS-Recursor                              |
| `password`    | `password`    | Password used to connect to PDNS API                           |
| `api_port`    | `8081`        | Listening port that PDNS API should bind to                    |
| `postgresql`  | *See Note 1*  | Configures PDNS to use PostgreSQL backend                      |
| `sqlite_path` | *See Note 1*  | Configures PDNS to use a non-default SQLite database           |


#### powerdns::server::authoritive

Configures PowerDNS Authoritive Name Server

| Parameter     | Default value | Description                                                    |
|---------------|---------------|----------------------------------------------------------------|
| `ensure`      | `present`     | Adds/removes PDNS                                              |
| `password`    | `password`    | Password used to connect to PDNS API                           |
| `port`        | `53`          | Listening port that PDNS should bind to                        |
| `api_port`    | `8081`        | Listening port that PDNS API should bind to                    |
| `postgresql`  | *See Note 1*  | Configures PDNS to use PostgreSQL backend                      |
| `sqlite_path` | *See Note 1*  | Configures PDNS to use a non-default SQLite database           |
| `recursor`    | *See Note 2*  | Configures PDNS to forward requests to a recursive name server |


#### powerdns::server::recursor

Configures PowerDNS Recursive Name Server

| Parameter | Default value | Description                                        |
|-----------|---------------|----------------------------------------------------|
| `ensure`  | `present`     | Adds/removes PDNS-Recursor                         |
| `address` | `127.0.0.1`   | Listening address that the recursor should bind to |
| `port`    | `1053`        | Listening port that the recursor should bind to    |


#### powerdns::databases::postgresql

Configures PostgreSQL database backend

| Parameter | Default value | Description                           |
|-----------|---------------|---------------------------------------|
| `ensure`  | `present`     | Adds/removes PostgreSQL resources     |
| `config`  | *See Note 1*  | Configures PostgreSQL database schema |


#### powerdns::databases::sqlite

Configures SQLite database backend

| Parameter | Default value           | Description                                               |
|-----------|-------------------------|-----------------------------------------------------------|
| `ensure`  | `present`               | Adds/removes SQLite resources                             |
| `path`    | `/var/lib/pdns/pdns.db` | Absolute path where SQLite database will be stored        |
| `user`    | `pdns`                  | User account which should be used to create database file |

---
## Notes

#### 1. Configuring databases

#### 2. Configuring PowerDNS to forward requests
