v1.5.0 [unreleased]
-------------------

### Features
-   [#172](https://github.com/latera/homs/pull/172) Do not use custom docker images for Postgres containers.
-   [#175](https://github.com/latera/homs/pull/175) Allow using environment variables in YAML configs.
-   [#167](https://github.com/latera/homs/pull/167) Add production docker-compose file for Oracle.
-   [#166](https://github.com/latera/homs/pull/166), [#7](https://github.com/latera/activiti-homs-docker/pull/7) Pass host, user and pass to waiting for Postgres script.
-   [#159](https://github.com/latera/homs/pull/159) Add tagged logger.
-   [#169](https://github.com/latera/homs/pull/169) Remove overflowing of deprecation warnings in tests.
-   [#161](https://github.com/latera/homs/pull/161), [#6](https://github.com/latera/activiti-homs-docker/pull/6) Use activiti credentials from environment variables.
-   [#151](https://github.com/latera/homs/pull/151) Add current version to docker container.
-   [#151](https://github.com/latera/homs/pull/152) Remove libqtwebkit-dev.
-   [#177](https://github.com/latera/homs/pull/177) Improve README and docker-compose files.
-   [#171](https://github.com/latera/homs/pull/171) Migrate from CoffeeScript to ES6 + Webpack.
-   [#179](https://github.com/latera/homs/pull/179) Replace `jquery-ui` tooltip with `popper.js`.
-   [#184](https://github.com/latera/homs/pull/184) Add `base_url` option to main config provides custom prefix for all paths in app. Fixes [#148](https://github.com/latera/homs/issues/148).    
-   [#185](https://github.com/latera/homs/pull/185) Speed up docker build.
-   [#187](https://github.com/latera/homs/pull/187) Use env file in homs's apps

### Bugfixes
-   [#170](https://github.com/latera/homs/pull/170) Use active support logger as base.

v1.4.0.2 [unreleased]
---------------------
### Bugfixes
-   [#165](https://github.com/latera/homs/pull/165) Remove new line from BPM widget basic auth generator.
-   [#174](https://github.com/latera/homs/pull/174) Remove unnecessary scroll in BPM widget select tables.
-   [#176](https://github.com/latera/homs/pull/176) Fix limits on the number of lines from sql requests.

v1.4.0.1 [2018-10-08]
---------------------

### Breaking changes

-   Changed default BPM engine from `activiti` to `camunda`. See [#149](https://github.com/latera/homs/pull/149) for details. Now you can set BPM engine in your `hbw.yml`. Example is in `hbw.yml.sample`, key `adapter`.

### Features
-   [#149](https://github.com/latera/homs/pull/149) Support Camunda as BPM engine.
-   [#146](https://github.com/latera/homs/pull/146) Replace PhantomJS with Capybara Webkit.
-   [#133](https://github.com/latera/homs/pull/133) Reduce docker images size by using `ruby:slim`.
-   [#144](https://github.com/latera/homs/pull/144) Reduce test execution time after Rails 5 upgrade.
-   [#147](https://github.com/latera/homs/pull/147) Improve manual installation instruction.
-   [#135](https://github.com/latera/homs/pull/135) Add `minio` image to `docker-compose.yml`.
-   [#136](https://github.com/latera/homs/pull/136) Reduce production docker image size by removing `libqtwebkit`.
-   [#156](https://github.com/latera/homs/pull/156) Rename initializer.
-   [#154](https://github.com/latera/homs/pull/154) Rename config for BPM engine.

### Bugfixes
-   [#5](https://github.com/latera/activiti-homs-docker/pull/5), [#1](https://github.com/latera/activiti-docker/pull/1) Fix activiti for homs docker image.
-   [#162](https://github.com/latera/homs/pull/162) Make sync request for checking BPM user. Prevents BPM widget rendering failure.
-   [#158](https://github.com/latera/homs/pull/158) Do not return empty element in case of missing BPM user.
-   [#157](https://github.com/latera/homs/pull/157) Fix GET request headers.
-   [#160](https://github.com/latera/homs/pull/160) Do not validate strings without pattern.
-   [#163](https://github.com/latera/homs/pull/163) Fix getting `NUMBER` from Oracle source.
-   [#155](https://github.com/latera/homs/pull/155) Add relative paths to `camunda` adapter.
-   [#145](https://github.com/latera/homs/pull/145) Fix `string` pattern usage and remove dependency from `jquery.formatter`.
-   [#140](https://github.com/latera/homs/pull/140) Submit form with files.
-   [#142](https://github.com/latera/homs/pull/142) Fix form-submit after Rails 5 upgrade.
-   [#134](https://github.com/latera/homs/pull/134) Validate arbitrary keys for profiles.
