_                   = require 'lodash'
moment              = require 'moment'
MissingEventsSetup  = require './src/missing-events-verifier-setup'
EmitterDevice       = require './src/emitter-device'
SubscriberDevice    = require './src/subscriber-device'
stats               = require 'simple-statistics'

MAX_SIZE = 30
class Command
  constructor: ->
    @times =           []
    @numberOfUpdates = 0
    @count = 0

    @missingEventsSetup  = new MissingEventsSetup()
    @history = []

  missedMessage: =>
    console.error "\nDidn't see a config event after #{@numberOfUpdates} times"
    process.exit -1

  change: ({data}={}) =>
    @changedTwice = _.after 2, @change
    duration = Date.now() - @start
    @numberOfUpdates = data?.timesChanged || 0

    if duration != 0
      @history.unshift {duration, @subscriberTime, @emitterTime, @changeTime}
      @history.length = MAX_SIZE if @history.length > MAX_SIZE
      @count++

    @printStats duration
    clearTimeout @deadmanSwitch
    @deadmanSwitch = setTimeout @missedMessage, 60000

    @start = Date.now()
    @emitter.change (error) =>
      @changeTime = Date.now() - @start
      if error?
        console.error "ERROR CHANGING!"
        console.error error.stack
        process.exit -1

  panic: (error) =>
    console.error error.stack
    process.exit 1

  printStats: (duration) =>
    return unless @history.length > 0
    console.log "##{@count}:"
    console.log "S: #{@subscriberTime}. Average: #{stats.mean _.map @history, 'subscriberTime'}"
    console.log "E: #{@emitterTime}. Average: #{stats.mean _.map @history, 'emitterTime'}"
    console.log "C: #{@changeTime}. Average: #{stats.mean _.map @history, 'changeTime'}"
    console.log "T: #{duration}. Average: #{stats.mean _.map @history, 'duration'}"

  run: =>
    @missingEventsSetup.setupDevices (error, {subscriberAuth, emitterAuth}={}) =>
      if error?
        console.error error.stack
        process.exit -1

      @emitter      = new EmitterDevice emitterAuth
      @subscriber   = new SubscriberDevice subscriberAuth
      @changedTwice = _.after 2, @change

      @emitter.listen =>
        console.log 'emitter listened'
        @emitter.on 'message', (data) =>
          @emitterTime = (Date.now() - @start) - @changeTime
          @changedTwice data

        @subscriber.listen (error) =>
          return @panic error if error?
          console.log 'subscriber listened'

          @subscriber.on 'message', (data) =>
            @subscriberTime = (Date.now() - @start) - @changeTime
            @changedTwice data

          @start = Date.now()
          @change()



command = new Command()
command.run()
