# Hydra Order Management System (HOMS)

*HOMS* is an open source web application for order and business process management.

Application consists of three parts:

* User interface - managing orders and tasks for registered users (Single Page Application).
* Administrator interface - managing users and order types.
* REST API - operations with orders and users.

Requirements:

* [Docker](https://docker.com/)
* [docker-compose](https://docs.docker.com/compose/install/)

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
    
2. For OS X users: make path to folder with config shared in `Docker -> Preferences... -> File Sharing`.

3. Set `SECRET_KEY_BASE` variable in your `.env` with uniq id as value. You can generate key with `openssl rand -hex 64` command. For example:

    ```bash
    SECRET_KEY_BASE=0750fd0eac13032778f0a42e2ab450003eaece477ea881501be0cc438f870a2f498dbbc00ffb7c8379c30c960568a402d315496bb7bc2b3ee324401ba788a
    ```

    :warning: Make sure this key is secret and don't share it with anyone.

4. Change [Minio](https://github.com/minio/minio) credentials in `.env` file. Generate `MINIO_ACCESS_KEY` and `MINIO_SECRET_KEY` values with any credentials generator, e.g. `pwgen 32 2`.

5. Run `docker-compose`:

    ```bash
    docker-compose up -d
    ```

6. Navigate to [Minio control panel](http://localhost:9000) and create a bucket with name equal to `MINIO_BUCKET_NAME` value from `.env` file.

7. Login to [HydraOMS](http://localhost:3000) with *`user@example.com`*/*`changeme`*. Now you are able to start Pizza Order demo process.

You can login to [Camunda Admin inteface](http://localhost:8766/camunda) with credentials equal to `BPM_USER:BPM_PASSWORD` values from `.env` file (`user/changeme` if these variables aren't set).

### In development

* [With Oracle Instant Client](https://github.com/latera/homs/blob/master/WITH_ORACLE.md).

* [Without Oracle Instant Client](https://github.com/latera/homs/blob/master/WITHOUT_ORACLE.md).

## Contributing/Development

The general development process is:

1. Fork this repo and clone it to your workstation.
2. Create a feature branch for your change.
3. Write code and tests.
4. Push your feature branch to github and open a pull request against master.

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

## License

Copyright (c) 2019 Latera LLC under the [Apache License](https://github.com/latera/homs/blob/master/LICENSE).
