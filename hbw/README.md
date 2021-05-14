# Hydra BPM Widget

## Widget integration steps

Import assets/hbw.js and assets/hbw.css (accessible via homs Url) into your application.

Set up your configuration file. Preferred configuration options are:
* `url` (homs address);
* `login` (homs user);
* `password` (homs user's API token);
* `entity_type` (type of tasks processed by BPM);
* `entity_code_attribute` (which attribute to use as identifier in BPM).

Initialize widget with following options:
* `entity_code` (in your configuration file);
* `entity_type` (in your configuration file);
* `autorunProcessKey` (business process type code which will be started automatically on Widget mount (if it isn't already started), don't set this parameter if you want to start your BP manually);
* `widgetContainer` (DOM selector of element for placing widget forms and buttons);
* `availableTasksButtonContainer` (DOM selector of element for placing user available tasks button);
* `availableTaskListContainer` (DOM selector of element for placing user available task list);
* `widgetPath` (path used by widget for sending HTTP-requests);
* `widgetURL` (URL used to WebSocket connection with widget backend);
* `taskListPath` (relative path to page with task list mounted to `availableTaskListContainer`);
* `userIdentifier` (email of user in HOMS);
* `locale` (object):
    * `code` (available values are 'en', 'ru')
    * `dateTimeFormat` (format for dates according to [Unicode Technical Standard #35](https://www.unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table))

After successful initialization widget would send HTTP-requests to get list of tasks and forms for current entity type.
You need to proxy these requests in your application to homs using basic authorization (get user and password from your configuration file) and adding special parameters for BPM:
* `user_identifier` (email of user in homs);
* `entity_type` (in your configuration file);
* `entity_code` (in your configuration file).
