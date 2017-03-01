{assert} = require 'chai'

{runDreddCommand, createServer, DEFAULT_SERVER_PORT} = require '../helpers'
{isProcessRunning, killAll} = require './helpers'


NON_EXISTENT_PORT = DEFAULT_SERVER_PORT + 1


describe 'CLI - Server Process', ->

  describe 'When specified by URL', ->
    server = undefined
    serverRuntimeInfo = undefined

    beforeEach (done) ->
      app = createServer()

      app.get '/machines', (req, res) ->
        res.send [{type: 'bulldozer', name: 'willy'}]

      app.get '/machines/willy', (req, res) ->
        res.send {type: 'bulldozer', name: 'willy'}

      server = app.listen (err, info) ->
        serverRuntimeInfo = info
        done(err)

    afterEach (done) ->
      server.close(done)


    describe 'When is running', ->
      dreddCommandInfo = undefined
      args = ['./test/fixtures/single-get.apib', "http://127.0.0.1:#{DEFAULT_SERVER_PORT}"]

      beforeEach (done) ->
        runDreddCommand args, (err, info) ->
          dreddCommandInfo = info
          done(err)

      it 'should request /machines', ->
        assert.deepEqual serverRuntimeInfo.requestCounts, {'/machines': 1}
      it 'should exit with status 0', ->
        assert.equal dreddCommandInfo.exitStatus, 0

    describe 'When is not running', ->
      dreddCommandInfo = undefined
      args = ['./test/fixtures/apiary.apib', "http://127.0.0.1:#{NON_EXISTENT_PORT}"]

      beforeEach (done) ->
        runDreddCommand args, (err, info) ->
          dreddCommandInfo = info
          done(err)

      it 'should return understandable message', ->
        assert.include dreddCommandInfo.stdout, 'Error connecting'
      it 'should report error for all transactions', ->
        occurences = (dreddCommandInfo.stdout.match(/Error connecting/g) or []).length
        assert.equal occurences, 5
      it 'should return stats', ->
        assert.include dreddCommandInfo.stdout, '5 errors'
      it 'should exit with status 1', ->
        assert.equal dreddCommandInfo.exitStatus, 1


  describe 'When specified by -g/--server', ->

    afterEach ->
      killAll()

    describe 'When works as expected', ->
      dreddCommandInfo = undefined
      args = [
        './test/fixtures/single-get.apib'
        "http://127.0.0.1:#{DEFAULT_SERVER_PORT}"
        "--server=coffee ./test/fixtures/scripts/dummy-server.coffee #{DEFAULT_SERVER_PORT}"
        '--server-wait=1'
      ]

      beforeEach (done) ->
        runDreddCommand args, (err, info) ->
          dreddCommandInfo = info
          done(err)

      it 'should inform about starting server with custom command', ->
        assert.include dreddCommandInfo.stdout, 'Starting backend server process with command'
      it 'should redirect server\'s welcome message', ->
        assert.include dreddCommandInfo.stdout, "Dummy server listening on port #{DEFAULT_SERVER_PORT}"
      it 'should exit with status 0', ->
        assert.equal dreddCommandInfo.exitStatus, 0


    for scenario in [
        description: 'When crashes before requests'
        apiDescriptionDocument: './test/fixtures/single-get.apib'
        server: './test/fixtures/scripts/exit_3.sh'
        expectServerBoot: false
      ,
        description: 'When crashes during requests'
        apiDescriptionDocument: './test/fixtures/apiary.apib'
        server: "coffee ./test/fixtures/scripts/dummy-server-crash.coffee #{DEFAULT_SERVER_PORT}"
        expectServerBoot: true
      ,
        description: 'When killed before requests'
        apiDescriptionDocument: './test/fixtures/single-get.apib'
        server: './test/fixtures/scripts/kill-self.sh'
        expectServerBoot: false
      ,
        description: 'When killed during requests'
        apiDescriptionDocument: './test/fixtures/apiary.apib'
        server: "coffee ./test/fixtures/scripts/dummy-server-kill.coffee #{DEFAULT_SERVER_PORT}"
        expectServerBoot: true
    ]
      do (scenario) ->
        describe scenario.description, ->
          dreddCommandInfo = undefined
          args = [
            scenario.apiDescriptionDocument
            "http://127.0.0.1:#{DEFAULT_SERVER_PORT}"
            "--server=#{scenario.server}"
            '--server-wait=1'
          ]

          beforeEach (done) ->
            runDreddCommand args, (err, info) ->
              dreddCommandInfo = info
              done(err)

          it 'should inform about starting server with custom command', ->
            assert.include dreddCommandInfo.stdout, 'Starting backend server process with command'
          if scenario.expectServerBoot
            it 'should redirect server\'s boot message', ->
              assert.include dreddCommandInfo.stdout, "Dummy server listening on port #{DEFAULT_SERVER_PORT}"
          it 'the server should not be running', ->
            assert.isFalse isProcessRunning scenario.server
          it 'should report problems with connection to server', ->
            assert.include dreddCommandInfo.stderr, 'Error connecting to server'
          it 'should exit with status 1', ->
            assert.equal dreddCommandInfo.exitStatus, 1


    describe 'When didn\'t terminate and had to be killed by Dredd', ->
      dreddCommandInfo = undefined
      args = [
        './test/fixtures/single-get.apib'
        "http://127.0.0.1:#{DEFAULT_SERVER_PORT}"
        "--server=coffee ./test/fixtures/scripts/dummy-server-nosigterm.coffee #{DEFAULT_SERVER_PORT}"
        '--server-wait=1'
      ]

      beforeEach (done) ->
        runDreddCommand args, (err, info) ->
          dreddCommandInfo = info
          done(err)

      it 'should inform about starting server with custom command', ->
        assert.include dreddCommandInfo.stdout, 'Starting backend server process with command'
      it 'should inform about sending SIGTERM', ->
        assert.include dreddCommandInfo.stdout, 'Sending SIGTERM to backend server process'
      it 'should redirect server\'s message about ignoring SIGTERM', ->
        assert.include dreddCommandInfo.stdout, 'ignoring sigterm'
      it 'should inform about sending SIGKILL', ->
        assert.include dreddCommandInfo.stdout, 'Killing backend server process'
      it 'the server should not be running', ->
        assert.isFalse isProcessRunning scenario.server
      it 'should exit with status 0', ->
        assert.equal dreddCommandInfo.exitStatus, 0
