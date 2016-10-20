.. _index:

Dredd — HTTP API Testing Framework
==================================

|Build Status| |Dependency Status| |devDependency Status| |Coverage Status| |Join the chat at https://gitter.im/apiaryio/dredd|

|Dredd - HTTP API Testing Framework|

    **Dredd is a language-agnostic command-line tool for validating
    API description document against backend implementation of the
    API.**

Dredd reads your API description and step by step validates whether your API implementation replies with responses as they are described in the documentation.

Supported API Description Formats
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  `API Blueprint <http://apiblueprint.org/>`__
-  `Swagger <http://swagger.io/>`__

Supported Hooks Languages
~~~~~~~~~~~~~~~~~~~~~~~~~

Dredd supports writing `hooks <hooks.md>`__ — a glue code for each test setup and teardown. Following languages are supported:

-  `Go <hooks-go.md>`__
-  `Node.js
   (JavaScript) <hooks-nodejs.md>`__
-  `Perl <hooks-perl.md>`__
-  `PHP <hooks-php.md>`__
-  `Python <hooks-python.md>`__
-  `Ruby <hooks-ruby.md>`__

.. note::

    Didn't find your favorite language? `Add a new one! <hooks-new-language.md>`__

Continuous Integration Support
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  `Travis CI <https://travis-ci.org/>`__
-  `CircleCI <https://circleci.com/>`__
-  `Jenkins <http://jenkins-ci.org/>`__
-  ...and any other \*nix based CI!

Documentation Reference
~~~~~~~~~~~~~~~~~~~~~~~

.. toctree::
    :maxdepth: 1

    About Dredd <self>
    quickstart
    how-it-works
    how-to-guides
    usage
    hooks
    Data Structures <data-structures>
    contributing

Useful Links
~~~~~~~~~~~~

-  `GitHub Repository <https://github.com/apiaryio/dredd>`__
-  `Bug Tracker <https://github.com/apiaryio/dredd/issues>`__
-  `Changelog <https://github.com/apiaryio/dredd/releases>`__
-  :ref:`genindex`
-  :ref:`search`

Example Applications
~~~~~~~~~~~~~~~~~~~~

-  `Express.js <http://github.com/apiaryio/dredd-example>`__
-  `Ruby on Rails <https://gitlab.com/theodorton/dredd-test-rails/>`__

.. |Build Status| image:: https://travis-ci.org/apiaryio/dredd.svg?branch=master
   :target: https://travis-ci.org/apiaryio/dredd
.. |Dependency Status| image:: https://david-dm.org/apiaryio/dredd.svg
   :target: https://david-dm.org/apiaryio/dredd
.. |devDependency Status| image:: https://david-dm.org/apiaryio/dredd/dev-status.svg
   :target: https://david-dm.org/apiaryio/dredd#info=devDependencies
.. |Coverage Status| image:: https://coveralls.io/repos/apiaryio/dredd/badge.svg?branch=master
   :target: https://coveralls.io/r/apiaryio/dredd?branch=master
.. |Join the chat at https://gitter.im/apiaryio/dredd| image:: https://badges.gitter.im/Join%20Chat.svg
   :target: https://gitter.im/apiaryio/dredd?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge
.. |Dredd - HTTP API Testing Framework| image:: https://raw.github.com/apiaryio/dredd/master/img/dredd.png?v=3&raw=true
