v1.8.0 [unreleased]
-------------------
- [#283](https://github.com/latera/homs/pull/283) Seed improvements: add env variables for initial values
- [#288](https://github.com/latera/homs/pull/288) Add drag and drop field for file upload.
- [#309](https://github.com/latera/homs/pull/309) Add error boundaries to all form components.

### Changes
Change serialization of disable, read only and hidden fields. Now all values of these fields will not be submitted.   
See [#296](https://github.com/latera/homs/pull/296) for more details.

### Features
- [#289](https://github.com/latera/homs/pull/289) Make conditions `disable_if` and `delete_if` dynamic.
- [#294](https://github.com/latera/homs/pull/294) Add test for dynamic disable and delete.

### Bugfixes
- [#298](https://github.com/latera/homs/pull/298) Keep BP variables values after submit if they are not on form or disabled.

### Breaking changes
    
-   `select_table` with `multi:true` saves all data in JSON format now. It's not possible to open form contains old data with such table.     
    See [#300](https://github.com/latera/homs/pull/300) for more details.

v1.7.2 [unreleased]
-------------------
### Bugfixes
- [#301](https://github.com/latera/homs/pull/301) Change deprecated `render nothing: true` to `head`.

v1.7.1 [2019-05-17]
-------------------

### Features
-   [#277](https://github.com/latera/homs/pull/277) Allow to configure widget polling interval.
-   [#275](https://github.com/latera/homs/pull/275) Set logging level from env file.
-   [#274](https://github.com/latera/homs/pull/274) Add duration of requests logging.
-   [#278](https://github.com/latera/homs/pull/278) Migrate from thin to unicorn.
-   [#284](https://github.com/latera/homs/pull/284) Try to reconnect if got Oracle connection error.
-   [#272](https://github.com/latera/homs/pull/272) Better view for multiple BP buttons.

v1.7.0 [2019-04-25]
-------------------

### Breaking changes

-   Dropped `activiti` support:
    - changed `activiti` to `camunda` in all `docker-compose` files
    - removed `docker-compose.activiti.yml`
    - sources type `static/activiti` was renamed to `static/bpm` in `config/sources.yml`
    - key `use_activiti_stub` was renamed to `use_bpm_stub` in ` config/hbw.yml`

    See [#253](https://github.com/latera/homs/pull/253) for more details.

### Features
-   [#248](https://github.com/latera/homs/pull/248) Add Rubocop.
-   [#251](https://github.com/latera/homs/pull/251) Update react-select up to 2.1.1.
-   [#253](https://github.com/latera/homs/pull/253) Drop Activiti support.
-   [#258](https://github.com/latera/homs/pull/258) Update React & ReactDOM to 16.0.0
-   [#259](https://github.com/latera/homs/pull/259) Get number of tasks by request to Camunda.
-   [#268](https://github.com/latera/homs/pull/268) Move validation of `select` and `select_table` to helpers.
-   [#273](https://github.com/latera/homs/pull/273) Change colors on select and hover of `select_table`.
-   [#276](https://github.com/latera/homs/pull/276) Fetch tasks for one entity by default.

v1.6.1 [unreleased]
-------------------

### Features
-   [#246](https://github.com/latera/homs/pull/246) Download Font Awesome when widget is loaded.

### Bugfixes
-   [#241](https://github.com/latera/homs/pull/241) Fix chevron reaction on task collapse.
-   [#242](https://github.com/latera/homs/pull/242) Search file_list field in nested field sets.
-   [#243](https://github.com/latera/homs/pull/243) Fix database port config usage.
-   [#245](https://github.com/latera/homs/pull/245) Disable business process buttons when loading.
-   [#247](https://github.com/latera/homs/pull/247) Use internal ports in homs_network.
-   [#250](https://github.com/latera/homs/pull/250) Fix file uploading.
-   [#252](https://github.com/latera/homs/pull/252) Fix `select_table` behavior in multi mode.
-   [#257](https://github.com/latera/homs/pull/257) Check flag `multi` in `select_table` when select row.
-   [#262](https://github.com/latera/homs/pull/262) Fix multi nullable `select_table`.
-   [#265](https://github.com/latera/homs/pull/265) Allow nullability for `select` lookup mode.
-   [#264](https://github.com/latera/homs/pull/264) Fix required `select` with numeric value.
-   [#267](https://github.com/latera/homs/pull/267) Fix widget calendar locale.
-   [#270](https://github.com/latera/homs/pull/270) Fix task collapse.

v1.6.0 [2019-01-29]
-------------------

### Features
-   [#189](https://github.com/latera/homs/pull/189) Show alert if form with file upload field has no file list field.
-   [#197](https://github.com/latera/homs/pull/197) Use Camunda as BPMS in default docker-compose.
-   [#195](https://github.com/latera/homs/pull/195) Upgrade React & ReactDOM to 15.6.2, migrate to higher order components from mixins.
-   [#153](https://github.com/latera/homs/pull/153) Allow updating users encrypted password and salt.
-   [#202](https://github.com/latera/homs/pull/202) Remove mount configs from docker-compose and set postgres version.
-   [#206](https://github.com/latera/homs/pull/206) Use higher order component instead of HBWDeleteIfMixin.
-   [#203](https://github.com/latera/homs/pull/203) Allow to unmount widget and replace some glyphicons with FontAwesome.
-   [#199](https://github.com/latera/homs/pull/199) Move assets generation to Dockerfiles.
-   [#207](https://github.com/latera/homs/pull/207) Remove extra locales from moment.js
-   [#209](https://github.com/latera/homs/pull/209) Drop react-rails & react_ujs dependencies.
-   [#205](https://github.com/latera/homs/pull/205) Use higher order component instead of HBWSelectMixin.
-   [#213](https://github.com/latera/homs/pull/213) Add payload to widget's requests.
-   [#218](https://github.com/latera/homs/pull/218) Pass initial BP variables to widget initial payload.
-   [#223](https://github.com/latera/homs/pull/223) Add directories for postgresql-client.
-   [#227](https://github.com/latera/homs/pull/227) Add `required` option for string inputs. Use `nullable: false` in select/select_table for the same reason.
-   [#230](https://github.com/latera/homs/pull/230) Add disable_if condition to checkbox, datetime, file_list, select, select_table, string, text.
-   [#232](https://github.com/latera/homs/pull/232) [**DEPRECATION**] Deprecate Activiti usage.
-   [#233](https://github.com/latera/homs/pull/233) Run DB on port specified in `.env` file.
-   [#231](https://github.com/latera/homs/pull/231) Add `multi` option to select_table.
-   [#240](https://github.com/latera/homs/pull/240) Update ruby up to 2.6.0.

### Bugfixes
-   [#194](https://github.com/latera/homs/pull/194) Set limit on the number of choices in lookup select from sql requests.
-   [#198](https://github.com/latera/homs/pull/198) Add seed in test's logs.
-   [#201](https://github.com/latera/homs/pull/201) Fix pointer on menu button.
-   [#219](https://github.com/latera/homs/pull/219) Update obsolete dependencies.
-   [#221](https://github.com/latera/homs/pull/221) Use babel-transform-runtime-plugin instead of babel-polyfill.
-   [#226](https://github.com/latera/homs/pull/226) Fix initial variables for Activiti.
-   [#229](https://github.com/latera/homs/pull/229) Add list of exceptions for binds, which are used for oracle's dates.
-   [#239](https://github.com/latera/homs/pull/239) Support empty date in select_table.

v1.5.3 [2019-01-16]
-------------------

### Bugfixes
-   [#220](https://github.com/latera/homs/pull/220) Fix error when using string's static pattern only.
-   [#224](https://github.com/latera/homs/pull/224) Fix type change in the order creation.

v1.5.2 [2018-11-27]
-------------------

### Features
-   [#215](https://github.com/latera/homs/pull/215) Use FontAwesome instead of Glyphicons in `bootstrap-datimepicker`.

### Bugfixes
-   [#217](https://github.com/latera/homs/pull/217) Add production as a default setting.

v1.5.1 [2018-11-14]
-------------------

### Bugfixes
-   [#204](https://github.com/latera/homs/pull/204) Pass locale for translations from environment.
-   [#211](https://github.com/latera/homs/pull/211) Fix lookup and change multi select to single.

v1.5.0 [2018-10-29]
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
-   [#188](https://github.com/latera/homs/pull/188) Use `.env` file in docker-compose.
-   [#183](https://github.com/latera/homs/pull/183) Replace `Select2` with `react-select` in widget.

### Bugfixes
-   [#170](https://github.com/latera/homs/pull/170) Use active support logger as base.
-   [#190](https://github.com/latera/homs/pull/190) Fix multiply running of tests in docker.

v1.4.0.2 [2018-12-10]
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
