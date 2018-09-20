# homs manual installation instruction

## Activiti installation

To install Activiti refer to [getting started guide](http://www.activiti.org/userguide/#_getting_started):

1. Be sure to use the same database for _activiti-explorer_ and _activiti-rest_ applications - internal H2 in-memory database does not satisfy this requirement.
2. Put [Latera Activiti extension jar](https://github.com/latera/activiti-ext) and its dependencies to `WEB-INF/lib` directory of each applications.
3. Create user with id *`user`*, email *`user@example.com`*, password *`changeme`* and include him in `users` security-role group.
4. Deploy [demo processes](https://github.com/latera/activiti-homs-demo).

One of the possible ways of Activiti installation with PostgreSQL database on Debian Linux is described below.

### Install required packages

```bash
sudo apt-get install tomcat8 tomcat8-admin postgresql
```

### Enable Tomcat manager interface

1. Add user with role `manager-gui` to tomcat-users.xml (`/etc/tomcat8/tomcat-users.xml`):
  
  ```
  <role rolename="manager-gui"/>
  <user username="tomcat" password="tomcat" roles="manager-gui"/>
  ```
2. Restart Tomcat:

  ```bash
  sudo service tomcat8 restart
  ```

### Create Activiti database

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

### Install Activiti

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
  * Download [Latera Activiti extension *full* pack](https://github.com/latera/activiti-ext/releases) and put it to `WEB-INF/lib` directory.
4. Zip back `activiti-explorer.war` and `activiti-rest.war`.
5. Deploy `activiti-explorer.war` and `activiti-rest.war` via Tomcat manager interface: [http://loclahost:8080/manager/html](http://loclahost:8080/manager/html)

### Deploy demo processes

1. Login at [http://localhost:8080/activiti-explorer](http://localhost:8080/activiti-explorer) with user *`kermit`* and password *`kermit`*.
2. Create user with id *`user`*, email *`user@example.com`*, password *`changeme`* and include him in `users` security-role group.
3. Deploy [demo processes](https://github.com/latera/activiti-homs-demo).


## homs installation

homs is a familiar Ruby On Rails 4 application with PostgreSQL backend. To install it you need _bundler_ and probably _rvm_.

One of the possible ways of homs installation on Debian Linux is described below.

### Install required packages

```bash
sudo apt-get install git postgresql libpq-dev nodejs libqtwebkit-dev
```

### Create homs database

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

### Install RVM

Follow [RVM installation guide](https://rvm.io/rvm/install).

### Install homs

1. Clone homs git repository:

  ```bash
  git clone https://github.com/latera/homs.git
  ```
2. Change directory
  ```bash
  cd homs
  ```
3. Install ruby:

  ```bash
  rvm install ruby-2.5.1
  ```
4. Create homs RVM gemset:

  ```bash
  rvm use ruby-2.5.1@homs --create
  ```
5. Install bundler:

  ```bash
  gem install bundler
  ```
6. Install gems:

  ```bash
  bundle --without oracle
  ```
7. Make configs from samples:

  ```bash
  find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
  ```
8. Update base_url of activiti service in config/bpm.yml

  ```
  development:
    base_url: http://<replace-host-name-here>:8080/activiti-rest/service/
    login: user
    password: changeme
  ```
9. Update host of database in config/database.yml

  ```
  <environment-name-here>:
    adapter: postgresql
    encoding: unicode
    pool: 5
    host: <replace-hostname-here>
    database: homs
    username: homs
    password: homs
  ```
10. Run migrations:

  ```bash
  bundle exec rake db:migrate
  ```
11. Fill db with test data:

  ```bash
  bundle exec rake db:seed
  ```

### Run homs

```bash
thin start --threaded
```

Login at [http://localhost:3000](http://localhost:3000) with *`user@example.com`*/*`changeme`*.
