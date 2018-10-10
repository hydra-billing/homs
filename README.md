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

There are 2 ways to install HOMS.

The prefered way to install HOMS is to use docker

### Using [docker](https://www.docker.com/)

#### In production

1. Install [docker-compose](https://docs.docker.com/compose/install/).
2. Download `docker-compose.yml`:

  ```
  wget https://raw.githubusercontent.com/latera/homs-docker/master/docker-compose.yml
  ```
3. For OS X users: make path to folder with HOMS shared in `Docker -> Preferences... -> File Sharing`.
4. Copy your (or default) configs to `/etc/hydra/homs/`:

  ```
  cp bpm.yml /etc/hydra/homs/bpm.yml
  cp database.yml /etc/hydra/homs/database.yml
  cp hbw.yml /etc/hydra/homs/hbw.yml
  cp homs_configuration.yml /etc/hydra/homs/homs_configuration.yml
  cp imprint.yml /etc/hydra/homs/imprint.yml
  cp sources.yml /etc/hydra/homs/sources.yml
  cp secrets.yml /etc/hydra/homs/secrets.yml
  ```
5. Add environment variables: `$HOMS_PATH` with path to your HOMS folder and [Minio](https://github.com/minio/minio) credentials:

  ```
  HOMS_PATH=/path/to/homs export HOMS_PATH
  MINIO_ACCESS_KEY=minio_access_key_from_hbw_yml export MINIO_ACCESS_KEY
  MINIO_SECRET_KEY=minio_secret_key_from_hbw_yml export MINIO_SECRET_KEY
  ```

6. Run `docker-compose`:
  ```
  docker-compose up -d
  ```

Login at [http://localhost:3000](http://localhost:3000) with *`user@example.com`*/*`changeme`*.

#### In development

If you don't want to use Oracle as source for your HOMS instance:

##### Without Oracle Instant Client

1. Clone HOMS git repository:

  ```
  git clone https://github.com/latera/homs.git
  ```
2. Make configs from samples:

  ```
  find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
  ```
3. Install docker-compose.
4. For OS X users: make path to folder with HOMS shared in `Docker -> Preferences... -> File Sharing`.
5. Add test environment to `config/database.yml`:

  ```
  development:
    adapter: postgresql
    encoding: unicode
    pool: 5
    host: postgres-homs
    database: homs
    username: homs
    password: homs
  ```
6. Add to `config/sources.yml`

  ```
  sources:
    bpmanagementsystem:
      type: static/activiti
  ```
7. Add environment variables: `$HOMS_PATH` with path to your HOMS folder and [Minio](https://github.com/minio/minio) credentials:

  ```
  HOMS_PATH=/path/to/homs export HOMS_PATH
  MINIO_ACCESS_KEY=minio_access_key_from_hbw_yml export MINIO_ACCESS_KEY
  MINIO_SECRET_KEY=minio_secret_key_from_hbw_yml export MINIO_SECRET_KEY
  ```

8. Run docker-compose:

  ```
  docker-compose -f docker-compose.dev.yml up -d
  ```
Login at [http://localhost:3000](http://localhost:3000) with *`user@example.com`*/*`changeme`*.

Or if you want to use Oracle as source for your HOMS instance

##### With Oracle Instant Client

Steps 1 – 5 are the same as for [without Oracle Instant Client installation](#without-oracle-instant-client)

6. Download the Oracle Instant Client 11.2 archives from OTN:

http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html

The following three ZIPs are required:

- `instantclient-basic-linux.x64-11.2.0.4.0.zip`
- `instantclient-sdk-linux.x64-11.2.0.4.0.zip`
- `instantclient-sqlplus-linux.x64-11.2.0.4.0.zip`

7. Place the downloaded Oracle Instant Client RPMs in the same directory as the `Dockerfile` and run:

```
docker build -t latera/homs-with-oracle -f Dockerfile.oracle .
```

8. Add to `config/sources.yml`

```
sources:
  bpmanagementsystem:
    type: static/activiti
  billing:
    type: sql/oracle
    tns_name: dbname
    username: user
    password: password
```

9. Add environment variables: `$HOMS_PATH` with path to your HOMS folder, `$TNSNAMES_PATH` with path to your `tnsnames.ora` file and [Minio](https://github.com/minio/minio) credentials:

```
HOMS_PATH=/path/to/homs export HOMS_PATH
TNSNAMES_PATH=/path/to/tnsnames.ora export TNSNAMES_PATH
MINIO_ACCESS_KEY=minio_access_key_from_hbw_yml export MINIO_ACCESS_KEY
MINIO_SECRET_KEY=minio_secret_key_from_hbw_yml export MINIO_SECRET_KEY
```
for access to host machine OS X users can use special DNS name `host.docker.internal` as host in `tnsnames.ora` ([details](https://docs.docker.com/docker-for-mac/networking))

10. Run docker-compose:
```
docker-compose -f docker-compose.dev.oracle.yml up -d
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
