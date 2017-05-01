MeshbluFirehose   = require 'meshblu-firehose-socket.io'
{EventEmitter2}   = require 'eventemitter2'

class SubscriberDevice extends EventEmitter2

  constructor: (@meshbluAuth) ->
    @meshbluAuth.port     = process.env.MESHBLU_FIREHOSE_PORT
    @meshbluAuth.protocol = 'http'

    @firehose = new MeshbluFirehose meshbluConfig: @meshbluAuth
    @firehose.on 'message', (data) =>
      @emit 'message', data

    @firehose.on 'error', (error) => console.error 'error', error.stack

  listen: (callback) =>
    @firehose.connect()
    @firehose.once 'connect', => callback()
    @firehose.once 'connect_error', (error) => callback(error)


module.exports = SubscriberDevice
