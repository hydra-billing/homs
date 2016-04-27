# Hydra Order Management System (homs)

*homs* is a web-application with frontend and REST API for managing configurable orders.

Application consists of three parts:
* User interface - managing orders for registered users (Single Page Application).
* Administer interface - managing users and order types.
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

### Activiti installation

To install Activiti refer to [getting started guide](http://www.activiti.org/userguide/#_getting_started):

1. Be sure to use the same database for _activiti-explorer_ and _activiti-rest_ applications - internal H2 in-memory database does not satisfy this requirement.
2. Put [Latera Activiti extension jar](https://github.com/latera/activiti-ext) and its dependencies to `WEB-INF/lib` directory of each applications.
3. Create user with id *`user`*, email *`user@example.com`*, password *`changeme`* and include him in `users` security-role group.
4. Deploy [demo processes](https://github.com/latera/activiti-homs-demo).

One of the possible ways of Activiti installation with PostgreSQL database on Debian Linux is described below.

#### Install required packages

```bash
sudo apt-get install tomcat8 tomcat8-admin postgresql
```

#### Enable Tomcat manager interface

1. Add user with role `manager-gui` to tomcat-users.xml (`/etc/tomcat8/tomcat-users.xml`):
  
  ```
  <role rolename="manager-gui"/>
  <user username="tomcat" password="tomcat" roles="manager-gui"/>
  ```
2. Restart Tomcat:

  ```bash
  sudo service tomcat8 restart
  ```

#### Create Activiti database

1. Connect to PostgreSQL as super user:

  ```bash
  sudo -u postgres psql
  ```
2. Create database, user and grant privileges:

  ```
  CREATE DATABASE activiti;
  CREATE USER activiti WITH password 'activiti';
  GRANT ALL privileges ON DATABASE activiti TO activiti;
  ```

#### Install Activiti

1. Download [Activiti 5.19.x](http://activiti.org/download.html) and unzip it.
2. Unzip `wars/activiti-explorer.war` and `wars/activiti-rest.war`.
3. For each application:
  * Replace content of `WEB-INF/classes/db.properties` with:
  
    ```
    db=postgres
    jdbc.driver=org.postgresql.Driver
    jdbc.url=jdbc:postgresql://localhost:5432/activiti
    jdbc.username=activiti
    jdbc.password=activiti
    ```
  * Download [PostgreSQL JDBC jar](https://jdbc.postgresql.org/download/postgresql-9.4.1207.jar) and put it to `WEB-INF/lib` directory.
  * Download [Latera Activiti extension *full* pack](https://github.com/latera/activiti-ext/releases) and put him to `WEB-INF/lib` directory.
4. Zip back `activiti-explorer.war` and `activiti-rest.war`.
5. Deploy `activiti-explorer.war` and `activiti-rest.war` via Tomcat manager interface: [http://loclahost:8080/manager/html](http://loclahost:8080/manager/html)

#### Deploy demo processes

1. Login at [http://localhost:8080/activiti-explorer](http://localhost:8080/activiti-explorer) with user *`kermit`* and password *`kermit`*.
2. Create user with id *`user`*, email *`user@example.com`*, password *`changeme`* and include him in `users` security-role group.
3. Deploy [demo processes](https://github.com/latera/activiti-homs-demo).


### homs installation

homs is familiar Ruby On Rails 4 application with PostgreSQL backend. To install it you need _bundler_ and probably _rvm_.

One of the possible ways of homs installation on Debian Linux is described below.

#### Install required packages

```bash
sudo apt-get install git postgresql libpq-dev nodejs
```

#### Create homs database

1. Connect to PostgreSQL as super user:

  ```bash
  sudo -u postgres psql
  ```
2. Create database, user, and grant privileges to him:

  ```
  CREATE DATABASE homs;
  CREATE USER homs WITH password 'homs';
  GRANT ALL privileges ON DATABASE homs TO homs;
  ```

#### Install RVM

Follow [RVM installation guide](https://rvm.io/rvm/install).

#### Install homs

1. Download source code by git:

  ```bash
  git clone https://github.com/latera/homs.git
  ```
2. Install ruby:

  ```bash
  rvm install ruby-2.2.4
  ```
3. Create homs RVM gemset:

  ```bash
  rvm use ruby-2.2.4@homs --create
  ```
4. Install bundler:

  ```bash
  gem install bundler
  ```
5. Install gems:

  ```bash
  bundle --without oracle
  ```
6. Make configs from samples:

  ```bash
  find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
  ```
7. Run migrations:

  ```bash
  bundle exec rake db:migrate
  ```

#### Run homs

```bash
thin start --threaded
```

Login at [http://localhost:3000](http://localhost:3000) with *`user@example.com`*/*`changeme`*.


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

