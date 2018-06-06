# Hydra Order Management System (homs)

*homs* is an open source web application for order and business process management.

Application consists of three parts:
* User interface - managing orders for registered users (Single Page Application).
* Administrator interface - managing users and order types.
* REST API - operations with orders and users.

Requirements:
* [PostgreSQL](http://www.postgresql.org/) 9.4.x+
* [Activiti](http://www.activiti.org/) 5.19.x
* [Latera Activiti extension](https://github.com/latera/activiti-ext)

Resources:
* Documentation: [http://hydra-oms.com/docs](http://hydra-oms.com/docs)
* Demo: [http://demo.hydra-oms.com](http://demo.hydra-oms.com)
* Community: [http://community.hydra-oms.com](http://community.hydra-oms.com)
* Tickets/Issues: [https://github.com/latera/homs/issues](https://github.com/latera/homs/issues)


## Installation

There are 2 ways to install homs.

### Using [docker](https://www.docker.com/)

1. Install [docker-compose](https://docs.docker.com/compose/install/).
2. Download `docker-compose.yml`:

  ```
  wget https://raw.githubusercontent.com/latera/homs-docker/master/docker-compose.yml
  ```
3. Create directories for db datafiles:

  ```
  mkdir -p /var/lib/hydra/activiti/postgresql
  mkdir -p /var/lib/hydra/homs/postgresql
  ```
4. For OS X users: add `/var/lib/hydra/activiti/postgresql` and `/var/lib/hydra/homs/postgresql` in `Docker -> Preferences... -> File Sharing`.
5. Copy your (or default) configs to `/etc/hydra/homs/`:

  ```
  cp activiti.yml /etc/hydra/homs/activiti.yml
  cp database.yml /etc/hydra/homs/database.yml
  cp hbw.yml /etc/hydra/homs/hbw.yml
  cp homs_configuration.yml /etc/hydra/homs/homs_configuration.yml
  cp imprint.yml /etc/hydra/homs/imprint.yml
  cp sources.yml /etc/hydra/homs/sources.yml
  cp secrets.yml /etc/hydra/homs/secrets.yml
  ```
6. Run `docker-compose`:
  ```
  docker-compose up -d
  ```

Login at [http://localhost:3000](http://localhost:3000) with *`user@example.com`*/*`changeme`*.

### Using [manual installation instruction](https://github.com/latera/homs/blob/master/INSTALL.md)

## Contributing/Development

The general development process is:

1. Fork this repo and clone it to your workstation.
2. Create a feature branch for your change.
3. Write code and tests.
4. Push your feature branch to github and open a pull request against master.

## Reporting Issues

Issues can be reported by using [GitHub Issues](https://github.com/latera/homs/issues).

## Testing

homs uses RSpec for unit/spec tests. You need to set up different testing database. Otherwise your development DB would be erased.

```bash
# Run all tests
bundle exec rspec spec

# Run a single test file
bundle exec rspec spec/PATH/TO/FILE_spec.rb

# Run a subset of tests
bundle exec rspec spec/PATH/TO/DIR
```

## License

Copyright (c) 2016 Latera LLC under the [Apache License](https://github.com/latera/homs/blob/master/LICENSE).

