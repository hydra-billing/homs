# Without Oracle Instant Client

If you don't want to use Oracle as source for your HOMS instance.

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

5. Add environment variable `$HOMS_URL` to `.env` file with URL to your HOMS:

    :pushpin: For access to host machine OS X users can use special DNS name `host.docker.internal` as host in `tnsnames.ora` ([details](https://docs.docker.com/docker-for-mac/networking)).

    ```bash
        HOMS_URL=http://docker.for.mac.localhost:3000/api
    ```

6. Create your own configs from samples:

    ```bash
    find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
    ```

7. Be sure to update secret key in `config/secrets.yml`. You can generate key with this command:

    ```bash
    openssl rand -hex 64
    ```

8. Add test environment to `config/database.yml`:

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

9. Run `docker-compose` with custom config:

    ```bash
    docker-compose -f docker-compose.dev.yml up -d
    ```

10. You can login to [Camunda Admin interface](http://localhost:8766/camunda) with credentials equal to `BPM_USER:BPM_PASSWORD` values from `.env` file (`user/changeme` if these variables aren't set).
