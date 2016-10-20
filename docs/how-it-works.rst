How It Works
============

In a nutshell, Dredd does following:

#. Takes your API description document,
#. creates expectations based on requests and responses documented in
   the document,
#. makes requests to tested API,
#. checks whether API responses match the documented responses,
#. reports the results.

Versioning
----------

Dredd follows `Semantic Versioning <http://semver.org/>`__. To ensure
certain stability of your Dredd installation (e.g. in CI), pin the
version accordingly. You can also use release tags:

-  ``npm install dredd`` - Installs the latest published version
   including experimental pre-release versions.
-  ``npm install dredd@stable`` - Skips experimental pre-release
   versions. Recommended for CI installations.

If the ``User-Agent`` header isn't overridden in the API description
document, Dredd uses it for sending information about its version number
along with every HTTP request it does.

Execution Life Cycle
--------------------

Following execution life cycle documentation should help you to
understand how Dredd works internally and which action goes after which.

#. Load and parse API description documents

   -  Report parse errors and warnings

#. Pre-run API description check

   -  Missing example values for URI template parameters
   -  Required parameters present in URI
   -  Report non-parseable JSON bodies
   -  Report invalid URI parameters
   -  Report invalid URI templates

#. Compile HTTP transactions from API description documents

   -  Inherit headers
   -  Inherit parameters
   -  Expand URI templates with parameters

#. Load `hooks <hooks.md>`__
#. Test run

   -  Report test run ``start``
   -  Run ``beforeAll`` hooks
   -  For each compiled transaction:

      -  Report ``test start``
      -  Run ``beforeEach`` hook
      -  Run ``before`` hook
      -  Send HTTP request
      -  Receive HTTP response
      -  Run ``beforeEachValidation`` hook
      -  Run ``beforeValidation`` hook
      -  `Perform validation <#automatic-expectations>`__
      -  Run ``after`` hook
      -  Run ``afterEach`` hook
      -  Report ``test end`` with result for in-progress reporting

   -  Run ``afterAll`` hooks

#. Report test run ``end`` with result statistics

Automatic Expectations
----------------------

Dredd automatically generates expectations on HTTP responses based on
examples in the API description with use of
`Gavel.js <https://github.com/apiaryio/gavel.js>`__ library. Please
refer to `Gavel <https://www.relishapp.com/apiary/gavel/docs>`__ rules
if you want know more.

Response Headers Expectations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  All headers specified in the API description must be present in the
   response.
-  Names of headers are validated in the case-insensitive way.
-  Only values of headers significant for content negotiation are
   validated.
-  All other headers values can differ.

When using `Swagger <http://swagger.io/>`__, headers are taken from
```response.headers`` <http://swagger.io/specification/#responseHeaders>`__.
HTTP headers significant for content negotiation are inferred according
to following rules:

-  ```produces`` <http://swagger.io/specification/#swaggerProduces>`__
   is propagated as response's ``Content-Type`` header.
-  Response's ``Content-Type`` header overrides any ``produces``.

    **Note:** There is a bug affecting the last item -
    `apiaryio/fury-adapter-swagger#65 <https://github.com/apiaryio/fury-adapter-swagger/issues/65>`__.

Response Body Expectations
~~~~~~~~~~~~~~~~~~~~~~~~~~

If the HTTP response body is JSON, Dredd validates only its structure.
Bodies in any other format are validated as plain text.

To validate the structure Dredd uses `JSON
Schema <http://json-schema.org/>`__ inferred from the API description
under test. The effective JSON Schema is taken from following places
(the order goes from the highest priority to the lowest):

API Blueprint
^^^^^^^^^^^^^

#. ```+ Schema`` <https://apiblueprint.org/documentation/specification.html#def-schema-section>`__
   section - provided custom JSON Schema (draft v4 or v3) will be used.
#. ```+ Attributes`` <https://apiblueprint.org/documentation/specification.html#def-attributes-section>`__
   section with data structure description in
   `MSON <https://github.com/apiaryio/mson>`__ - API Blueprint parser
   automatically generates JSON Schema from MSON.
#. ```+ Body`` <https://apiblueprint.org/documentation/specification.html#def-body-section>`__
   section with sample JSON payload -
   `Gavel.js <https://github.com/apiaryio/gavel.js>`__, which is
   responsible for validation in Dredd, automatically infers some basic
   expectations described below.

This order `exactly follows the API Blueprint
specification <https://apiblueprint.org/documentation/specification.html#relation-of-body-schema-and-attributes-sections>`__.

Swagger
^^^^^^^

#. ```response.schema`` <http://swagger.io/specification/#responseSchema>`__
   - provided JSON Schema will be used.
#. ```response.examples`` <http://swagger.io/specification/#responseExamples>`__
   with sample JSON payload -
   `Gavel.js <https://github.com/apiaryio/gavel.js>`__, which is
   responsible for validation in Dredd, automatically infers some basic
   expectations described below.

Gavel's Expectations
^^^^^^^^^^^^^^^^^^^^

-  All JSON keys on any level given in the sample must be present in the
   response's JSON.
-  Response's JSON values must be of the same JSON primitive type.
-  All JSON values can differ.
-  Arrays can have additional items, type or structure of the items is
   not validated.
-  Plain text must match perfectly.

Custom Expectations
~~~~~~~~~~~~~~~~~~~

You can make your own custom expectations in `hooks <hooks.md>`__. For
instance, check out how to employ `Chai.js
assertions <hooks.md#using-chai-assertions>`__.

Making Your API Description Ready for Testing
---------------------------------------------

It's very likely that your API description document will not be testable
**as is**. This section should help you to learn how to solve the most
common issues.

URI Parameters
~~~~~~~~~~~~~~

Both `API Blueprint <http://apiblueprint.org/>`__ and
`Swagger <http://swagger.io/>`__ allow usage of URI templates (API
Blueprint fully implements
`RFC6570 <https://tools.ietf.org/html/rfc6570>`__, Swagger templates are
much simpler). In order to have an API description which is testable,
you need to describe all required parameters used in URI (path or query)
and provide sample values to make Dredd able to expand URI templates
with given sample values. Following rules apply when Dredd interpolates
variables in a templated URI, ordered by precedence:

#. Sample value (available in Swagger as ```x-example`` vendor extension
   property <how-to-guides.md#example-values-for-request-parameters>`__).
#. Value of ``default``.
#. First value from ``enum``.

If Dredd isn't able to infer any value for a required parameter, it will
terminate the test run and complain that the parameter is *ambiguous*.

    **Note:** The implementation of API Blueprint's request-specific
    parameters is still in progress and there's only experimental
    support for it in Dredd as of now.

Request Headers
~~~~~~~~~~~~~~~

In `Swagger <http://swagger.io/>`__ documents, HTTP headers are inferred
from ```"in": "header"``
parameters <http://swagger.io/specification/#parameterObject>`__. HTTP
headers significant for content negotiation are inferred according to
following rules:

-  ```consumes`` <http://swagger.io/specification/#swaggerConsumes>`__
   is propagated as request's ``Content-Type`` header.
-  ```produces`` <http://swagger.io/specification/#swaggerProduces>`__
   is propagated as request's ``Accept`` header.
-  If request body parameters are specified as ``"in": "formData"``,
   request's ``Content-Type`` header is set to
   ``application/x-www-form-urlencoded``.

    **Note:** Processing ``"in": "header"`` parameters and inferring
    ``application/x-www-form-urlencoded`` from ``"in": "formData"``
    parameters is not implemented yet
    (`apiaryio/fury-adapter-swagger#68 <https://github.com/apiaryio/fury-adapter-swagger/issues/68>`__,
    `apiaryio/fury-adapter-swagger#67 <https://github.com/apiaryio/fury-adapter-swagger/issues/67>`__).

Request Body
~~~~~~~~~~~~

API Blueprint
^^^^^^^^^^^^^

The effective request body is taken from following places (the order
goes from the highest priority to the lowest):

#. ```+ Body`` <https://apiblueprint.org/documentation/specification.html#def-body-section>`__
   section with sample JSON payload.
#. ```+ Attributes`` <https://apiblueprint.org/documentation/specification.html#def-attributes-section>`__
   section with data structure description in
   `MSON <https://github.com/apiaryio/mson>`__ - API Blueprint parser
   automatically generates sample JSON payload from MSON.

This order `exactly follows the API Blueprint
specification <https://apiblueprint.org/documentation/specification.html#relation-of-body-schema-and-attributes-sections>`__.

Swagger
^^^^^^^

The effective request body is inferred from ```"in": "body"`` and
``"in": "formData"``
parameters <http://swagger.io/specification/#parameterObject>`__.

If body parameter has
```schema.example`` <http://swagger.io/specification/#schemaExample>`__,
it is used as a raw JSON sample for the request body. If it's not
present, Dredd's `Swagger
Adapter <https://github.com/apiaryio/fury-adapter-swagger/>`__ generates
sample values from the JSON Schema provided in the
```schema`` <http://swagger.io/specification/#parameterSchema>`__
property. Following rules apply when the adapter fills values of the
properties, ordered by precedence:

#. Value of ``default``.
#. First value from ``enum``.
#. Dummy, generated value.

How Dredd Works With HTTP Transactions
--------------------------------------

Multiple Requests and Responses
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

API Blueprint
^^^^^^^^^^^^^

| While `API Blueprint <http://apiblueprint.org/>`__ allows specifying
  multiple requests and responses in any
| combination (see specification for the `action
  section <https://apiblueprint.org/documentation/specification.html#def-action-section>`__),
  Dredd
| currently supports just separated HTTP transaction pairs like this:

::

    + Request
    + Response

    + Request
    + Response

In other words, Dredd always selects just the first response for each
request.

    **Note:** Improving the support for multiple requests and responses
    is under development. Refer to issues
    `#25 <https://github.com/apiaryio/dredd/issues/25>`__ and
    `#78 <https://github.com/apiaryio/dredd/issues/78>`__ for details.
    Support for URI parameters specific to a single request within one
    action is also limited. Solving
    `#227 <https://github.com/apiaryio/dredd/issues/227>`__ should
    unblock many related problems. Also see `Multiple Requests and
    Responses within One API Blueprint
    Action <how-to-guides.md#multiple-requests-and-responses-within-one-api-blueprint-action>`__
    guide for workarounds.

Swagger
^^^^^^^

| The `Swagger <http://swagger.io/>`__ format allows to specify multiple
  responses for a single operation.
| By default Dredd tests only responses with ``2xx`` status codes.
  Responses with other
| codes are marked as *skipped* and can be activated in
  `hooks <hooks.md>`__ - see `Testing non-2xx Responses with
  Swagger <how-to-guides.md#testing-non-2xx-responses-with-swagger>`__.

| `Default
  responses <http://swagger.io/specification/#responsesDefault>`__ are
  ignored by Dredd. Also, as of now,
| only ``application/json`` media type is supported in
  ```produces`` <http://swagger.io/specification/#swaggerProduces>`__
  and
  ```consumes`` <http://swagger.io/specification/#swaggerConsumes>`__.
| Other media types are skipped.
