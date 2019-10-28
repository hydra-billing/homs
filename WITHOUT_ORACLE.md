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

5. Create your own configs from samples:

    ```bash
    find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
    ```

6. Be sure to update secret key in `config/secrets.yml`. You can generate key with this command:

    ```bash
    openssl rand -hex 64
    ```

7. Add test environment to `config/database.yml`:

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

8. Run `docker-compose` with custom config:

    ```bash
    docker-compose -f docker-compose.dev.yml up -d
    ```

9. Navigate to [Camunda Admin](http://localhost:8080/camunda) and create admin user with credentials equal to `BPM_USER:BPM_PASSWORD` values from `.env` file.

10. (Optional) If you want to use demo processes, navigate to [Camunda](http://localhost:8080/camunda/app/admin/default/#/user-create) and create user with `user@example.com` email.

11. Log in at [HydraOMS](http://localhost:3000) with *`user@example.com`*/*`changeme`*.
