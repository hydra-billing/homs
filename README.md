# Hydra Order Management System (HOMS)

*HOMS* is an open source web application for order and business process management.

Application consists of three parts:

* User interface - managing orders and tasks for registered users (Single Page Application).
* Administrator interface - managing users and order types.
* REST API - operations with orders and users.

Requirements:

* [Docker](https://docker.com/)
* [docker-compose](https://docs.docker.com/compose/install/)

Compatibility:

* [Camunda 7.9.0 compatible](https://docs.camunda.org/manual/7.9/introduction/supported-environments/#supported-database-products) with PostgreSQL 9.1 / 9.3 / 9.4 / 9.6
* Minio[RELEASE.2021-06-17T00-10-46Z](https://github.com/minio/minio/releases/tag/RELEASE.2021-06-17T00-10-46Z)

Resources:

* Documentation: [http://hydra-oms.com/docs](http://hydra-oms.com/docs)
* Demo: [http://demo.hydra-oms.com](http://demo.hydra-oms.com)
* Community: [http://community.hydra-oms.com](http://community.hydra-oms.com)
* Tickets/Issues: [https://github.com/latera/homs/issues](https://github.com/latera/homs/issues)

## Installation

The prefered way to install HOMS is to use [Docker](https://www.docker.com/).

### In production

1. Download `docker-compose.yml` and default `.env` config file:

    ```bash
    wget https://raw.githubusercontent.com/latera/homs/master/docker-compose.yml
    wget https://raw.githubusercontent.com/latera/homs/master/.env.sample -O .env
    ```

    :pushpin: All variables are set in `.env` file. There you can change them, if you want to.

1. For OS X users: make path to folder with config shared in `Docker -> Preferences... -> File Sharing`.

1. Set `SECRET_KEY_BASE` variable in your `.env` with uniq id as value. You can generate key with `openssl rand -hex 64` command. For example:

    ```bash
    SECRET_KEY_BASE=0750fd0eac13032778f0a42e2ab450003eaece477ea881501be0cc438f870a2f498dbbc00ffb7c8379c30c960568a402d315496bb7bc2b3ee324401ba788a
    ```

    :warning: Make sure this key is secret and don't share it with anyone.

1. Change [Minio](https://github.com/minio/minio) credentials in `.env` file. Generate `MINIO_ACCESS_KEY` and `MINIO_SECRET_KEY` values with any credentials generator, e.g. `pwgen 32 2`.

1. Run `docker-compose`:

    ```bash
    docker-compose up -d
    ```

1. Navigate to [Minio control panel](http://localhost:9000) and create a bucket with name equal to `MINIO_BUCKET_NAME` value from `.env` file.

1. Login to [HydraOMS](http://localhost:3000) with *`user@example.com`*/*`changeme`*. Now you are able to start Pizza Order demo process.

You can login to [Camunda Admin interface](http://localhost:8766/camunda) with credentials equal to `BPM_USER:BPM_PASSWORD` values from `.env` file (`user/changeme` if these variables aren't set).

### In development
1. Follow the instructions below:
    * [With Oracle Instant Client](https://github.com/latera/homs/blob/master/WITH_ORACLE.md).

    * [Without Oracle Instant Client](https://github.com/latera/homs/blob/master/WITHOUT_ORACLE.md) (default way).

1. Navigate to [Minio control panel](http://localhost:9000) and create a bucket with name equal to `MINIO_BUCKET_NAME` value from `.env` file.
1. Export all variables from .env file
   ```
   export $(cat .env | xargs)
   ```
1. Change in bpm.yml value of development.base_url from `http://camunda:8080/engine-rest/` to `http://localhost:8766/engine-rest/`
1. In database.yml change value of development.host from `<%= ENV['HOMS_DB_HOST'] %>` to `localhost`
1. Install [Yarn](https://github.com/yarnpkg/yarn#installing-yarn) and run:
   ```
   yarn install
   ```

1. Compile assets:
    ```bash
    yarn dev
    ```
1. Start HOMS application in another console tab:
    ```bash
    rails s
    ```
1. Create and populate the database (adds an admin user, initial order types, and orders):
    ```bash
    rails db:migrate
    export SEED_DB=true
    rails db:seed
    ```
1. Log in at [HydraOMS](http://localhost:3000) with *`user@example.com`*/*`changeme`*.

### Work with SSO
Requirements:
* [Keycloak](https://www.keycloak.org/)

For using SSO with HOMS:
1. Add [user roles](https://www.keycloak.org/docs/latest/server_admin/index.html#con-client-roles_server_administration_guide). HOMS use "admin" and "user" client level roles. Only one role could be assigned to user.
2. Add [user attributes](https://www.keycloak.org/docs/latest/server_admin/index.html#proc-configuring-user-attributes_server_administration_guide) in Keycloak: `company`, `department`.
3. Add [mappers](https://www.keycloak.org/docs/latest/server_admin/index.html#_protocol-mappers) in Keycloak without prefix:

Name | Mapper type | User attribute | Token clain name | Claim JSON type | Add to ID token | Add to access token | Add to userinfo | Multivalued | Aggregate attributes values
--- | --- | --- | --- | --- | --- | --- | --- | --- | ---
`company` | `User Attribute` | `company` | `company` | string | On | On | On | Off | Off
`department` | `User Attribute` | `department` | `department` | string | On | On | On | Off | Off

3. Add to HOMS config file `homs_configuration.yml`:
```
sso:
  enabled: true
  use_regular_login: true
  keycloak:
    auth_server_url: "http://keycloak_host:keycloak_port/auth/"
    realm: hydra
    client_id: homs
    redirect_uri: "http://homs_host:homs_port/authenticate_by_keycloak"
    secret: "af9504fc-b030-405e-97b6-813220c07a7e"
    logout_redirect: "http://homs_host:homs_port"
    scope:
      - homs
```

### Filter business processes by user

Set `cadidate_starters.enabled` in `hbw.yml` to `true` to send user email to camunda when fetching business processes definition. That way you can allow users to run only certain business processes.

## Contributing/Development

The general development process is:

1. Fork this repo and clone it to your workstation.
1. Create a feature branch for your change.
1. Write code and tests.
1. Push your feature branch to github and open a pull request against master.

## Reporting Issues

Issues can be reported by using [GitHub Issues](https://github.com/latera/homs/issues).

## Testing

HOMS uses RSpec for unit/spec tests. You need to set up different testing database. Otherwise your development DB would be erased.

```bash
# Run all tests
bundle exec rspec spec

# Run a single test file
bundle exec rspec spec/PATH/TO/FILE_spec.rb

# Run a subset of tests
bundle exec rspec spec/PATH/TO/DIR
```

## Links

1. [Repo with helper classes for BPMN development](https://github.com/latera/camunda-ext).

1. [Example of creating a demo business process](https://github.com/latera/camunda-ext/tree/master/demo_processes).

## License

Copyright (c) 2019 Latera LLC under the [Apache License](https://github.com/latera/homs/blob/master/LICENSE).
