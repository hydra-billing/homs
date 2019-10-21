Contributing to homs
====================

Submitting a pull request
------------
To submit a pull request you should fork the homs repository, and make your change on a feature branch of your fork. Then generate a pull request from your branch against *master* of the homs repository. Include in your pull request details of your change -- the why *and* the how -- as well as the testing your performed. Also, be sure to run the test suite with your change in place. Changes that cause tests to fail cannot be merged.

There will usually be some back and forth as we finalize the change, but once that completes it may be merged.

You should update CHANGELOG.md.

Code style
------------
We are following several style guides:
* [Ruby Style Guide](https://rubystyle.guide)

* [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)

    With some notes:

    * [7.11](https://github.com/airbnb/javascript#functions--signature-spacing), 
    [19.3](https://github.com/airbnb/javascript#whitespace--around-keywords)
    Add spaces before and after paren in function declaration:
        ```javascript
        // bad
        const f = function(){};
        const g = function (){};
        const h = function() {};
        const j = function a() {};

        // good
        const x = function () {};
        const y = function a () {};
  
    * [16.3](https://github.com/airbnb/javascript#blocks--no-else-return)
    Else-return is allowed.

* [Airbnb React/JSX Style Guide](https://github.com/airbnb/javascript/tree/master/react)

    With some notes:

    * [React.createClass](https://github.com/airbnb/javascript/tree/master/react#class-vs-reactcreateclass-vs-stateless):

        Until we use ReactJS < `15.5.0` and mixins we have to use 
        ```javascript
        const Listing = React.createClass({
        // ...
        })
        ```
        instead of
        ```javasript
        class Listing extends React.Component {
        // ...
        }
        ```
