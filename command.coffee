_                   = require 'lodash'
MissingEventsSetup  = require './src/missing-events-verifier-setup'
EmitterDevice       = require './src/emitter-device'
SubscriberDevice    = require './src/subscriber-device'

class Command
  constructor: ->
    @times = 0
    @missingEventsSetup  = new MissingEventsSetup()

  missedMessage: =>
    console.error "Didn't see a config event after #{times} times"
    process.exit -1

  change: ({data}={}) =>
    @changedTwice = _.after 2, @change

    @times = data?.timesChanged || 0
    console.log @times
    clearTimeout @deadmanSwitch
    @deadmanSwitch = setTimeout @missedMessage, 5000

    @emitter.change (error) =>
      if error?
        console.error "ERROR CHANGING!"
        console.error error.stack
        process.exit -1

  run: =>
    @missingEventsSetup.setupDevices (error, {subscriberAuth, emitterAuth}) =>
      if error?
        console.error error.stack
        process.exit -1

      @emitter     = new EmitterDevice emitterAuth
      @subscriber  = new SubscriberDevice subscriberAuth
      @changedTwice = _.after 2, @change

      @emitter.listen =>
        console.log 'emitter listened'
        @emitter.on 'message', (data) =>
          process.stdout.write 'E'
          @changedTwice data

        @subscriber.listen =>
          console.log 'subscriber listened'

          @subscriber.on 'message', (data) =>
            process.stdout.write 'S'
            @changedTwice data
          @change()

command = new Command()
command.run()
