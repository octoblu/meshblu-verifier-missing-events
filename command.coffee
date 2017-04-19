_                   = require 'lodash'
MissingEventsSetup  = require './src/missing-events-verifier-setup'
EmitterDevice       = require './src/emitter-device'
missingEventsSetup  = new MissingEventsSetup()

times=0
deadmanSwitch=0

missedMessage = =>
  console.error "Didn't see a config event after #{times} times"
  process.exit -1


missingEventsSetup.setupDevices (error, {subscriberAuth, emitterAuth}) =>

  if error?
    console.error error.stack
    process.exit -1
  emitter = new EmitterDevice emitterAuth

  change = =>
    clearTimeout deadmanSwitch
    deadmanSwitch = setTimeout missedMessage, 5000
    emitter.change (error) =>
      if error?
        console.error "ERROR CHANGING!"
        console.error error.stack
        process.exit -1

  emitter.listen =>
    emitter.on 'message', ({data}) =>
      times = data.timesChanged
      console.log times
      change()

    change()
