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

The prefered way to install HOMS is to use Docker

### Using [docker](https://www.docker.com/)

#### In production

1. Install [docker-compose](https://docs.docker.com/compose/install/).
2. Download `docker-compose.yml`:

  ```
  wget https://raw.githubusercontent.com/latera/homs-docker/master/docker-compose.yml
  ```
3. For OS X users: make path to folder with HOMS shared in `Docker -> Preferences... -> File Sharing`.

4. Copy your (or default) `.env` file to your project's directory:

  ```
  cp .env.sample .env
  ```
  
   All variables are set in `.env` file. There you can change them, if you want to.

5. Change [Minio](https://github.com/minio/minio) credentials in `.env` file.

6. Be sure to update secret key in `/etc/hydra/homs/secrets.yml`. You can generate key with this command:

  ```
  openssl rand -hex 64
  ```

7. Run `docker-compose`:

  ```
  docker-compose up -d
  ```

8. Navigate to [Minio control panel](http://localhost:9000) and create a bucket with name equal to `MINIO_BUCKET_NAME` value from `.env` file.

9. Navigate to [Camunda Admin](http://localhost:8080/camunda) and create admin user with credentials equal to `BPM_USER:BPM_PASSWORD` values from `.env` file.

10. (Optional) If you want to use demo processes navigate to [Camunda](http://localhost:8080/camunda/app/admin/default/#/user-create) and create user with `user@example.com` email.

11. Login at [HydraOMS](http://localhost:3000) with *`user@example.com`*/*`changeme`*.

#### In development

If you don't want to use Oracle as source for your HOMS instance:

##### Without Oracle Instant Client

Follow the same steps as for [In production installation](#in-production), but with certain changes:

2. Clone HOMS git repository:

  ```
  git clone https://github.com/latera/homs.git
  ```

4.1. Create your own configs from samples:

  ```
  find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
  ```

6. Skip this step

7. Add test environment to `config/database.yml`:

  ```
  development:
    adapter: postgresql
    encoding: unicode
    pool: 5
    host: <%= ENV['HOMS_DB_HOST'] %>
    database: <%= ENV['HOMS_DB_NAME'] %>
    username: <%= ENV['HOMS_DB_USER'] %>
    password: <%= ENV['HOMS_DB_PASSWORD'] %>
  ```
  
8. Run `docker-compose`: with custom config:
  ```
  docker-compose -f docker-compose.dev.yml up -d
  ```

Or if you want to use Oracle as source for your HOMS instance:

##### With Oracle Instant Client

Follow the same steps as for [without Oracle Instant Client installation](#without-oracle-instant-client), but with certain changes:

5. Download the Oracle Instant Client 11.2 archives from OTN:

http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html

The following three ZIPs are required:

- `instantclient-basic-linux.x64-11.2.0.4.0.zip`
- `instantclient-sdk-linux.x64-11.2.0.4.0.zip`
- `instantclient-sqlplus-linux.x64-11.2.0.4.0.zip`

5.1. Place the downloaded Oracle Instant Client RPMs in the same directory as the `Dockerfile` and run:

```
docker build -t latera/homs-with-oracle -f Dockerfile.oracle .
```

5.2. Create `config/sources.yml` file with database credentials

```
sources:
  billing:
    type: sql/oracle
    tns_name: dbname
    username: user
    password: password
```

5.3. Add environment variable `$TNSNAMES_PATH` to `.env` file with path to your `tnsnames.ora` file:

```
TNSNAMES_PATH=/dir/with/tnsnames.ora
```

for access to host machine OS X users can use special DNS name `host.docker.internal` as host in `tnsnames.ora` ([details](https://docs.docker.com/docker-for-mac/networking))

6. Run `docker-compose`: with custom config:
  ```
  docker-compose -f docker-compose.dev.oracle.yml up -d
  ```

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

```
# Run all tests
bundle exec rspec spec

# Run a single test file
bundle exec rspec spec/PATH/TO/FILE_spec.rb

# Run a subset of tests
bundle exec rspec spec/PATH/TO/DIR
```

## License

Copyright (c) 2018 Latera LLC under the [Apache License](https://github.com/latera/homs/blob/master/LICENSE).
