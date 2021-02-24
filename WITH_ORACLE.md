# With Oracle Instant Client

If you want to use Oracle as source for your HOMS instance.

1. Install [docker-compose](https://docs.docker.com/compose/install/).

2. Clone HOMS git repository:

    ```bash
    git clone https://github.com/latera/homs.git
    ```

3. For OS X users: make path to folder with HOMS shared in `Docker -> Preferences... -> File Sharing`.

4. Copy your (or default) `.env` file to your project's directory:

    ```bash
    cp .env.sample .env
    ```

    :pushpin: All variables are set in `.env` file. There you can change them, if you want to.

5. Create your own configs from samples:

    ```bash
    find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
    ```

6. Be sure to update secret key in `config/secrets.yml`. You can generate key with this command:

    ```bash
    openssl rand -hex 64
    ```

7. Download the Oracle Instant Client 11.2 archives from OTN:

    <http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html>

    The following three ZIPs are required:

    - `instantclient-basic-linux.x64-11.2.0.4.0.zip`
    - `instantclient-sdk-linux.x64-11.2.0.4.0.zip`
    - `instantclient-sqlplus-linux.x64-11.2.0.4.0.zip`

8. Place the downloaded Oracle Instant Client RPMs in the same directory as the `Dockerfile` and run:

    ```bash
    docker build -t latera/homs-with-oracle -f Dockerfile.oracle .
    ```

9. Update `config/sources.yml` file with database credentials

    ```yml
    sources:
      billing:
        type: sql/oracle
        tns_name: dbname
        username: user
        password: password
    ```

10. Add environment variable `$TNSNAMES_PATH` to `.env` file with path to your `tnsnames.ora` file:

    ```bash
    TNSNAMES_PATH=/dir/with/tnsnames.ora
    ```

    :pushpin: For access to host machine OS X users can use special DNS name `host.docker.internal` as host in `tnsnames.ora` ([details](https://docs.docker.com/docker-for-mac/networking)).
11. Add environment variable `$HOMS_URL` to `.env` file with URL to your HOMS:

    ```bash
        HOMS_URL=http://docker.for.mac.localhost:3000/api
    ```

12. Add test environment to `config/database.yml`:

    ```yml
    development:
      adapter: postgresql
      encoding: unicode
      pool: 5
      host: <%= ENV['HOMS_DB_HOST'] %>
      port: <%= ENV['HOMS_DB_PORT'] %>
      database: <%= ENV['HOMS_DB_NAME'] %>
      username: <%= ENV['HOMS_DB_USER'] %>
      password: <%= ENV['HOMS_DB_PASSWORD'] %>
    ```

13. Run `docker-compose` with custom config:

    ```bash
    docker-compose -f docker-compose.oracle.yml up -d
    ```

14. You can login to [Camunda Admin interface](http://localhost:8766/camunda) with credentials equal to `BPM_USER:BPM_PASSWORD` values from `.env` file (`user/changeme` if these variables aren't set).
