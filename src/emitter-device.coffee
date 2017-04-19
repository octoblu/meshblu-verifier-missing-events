MeshbluHttp       = require 'meshblu-http'
MeshbluFirehose   = require 'meshblu-firehose-socket.io'
MeshbluConfig     = require 'meshblu-config'
{EventEmitter2}   = require 'eventemitter2'

class EmitterDevice extends EventEmitter2

  constructor: (@meshbluAuth) ->
    @meshbluHttp = new MeshbluHttp @meshbluAuth
    @firehose = new MeshbluFirehose meshbluConfig: @meshbluAuth
    @firehose.on 'message', (data) =>
      @emit 'message', data

    @firehose.on 'error', (error) => console.error 'error', error.stack

  listen: (callback) =>
    @firehose.connect()
    @firehose.once 'connect', => callback()
    @firehose.once 'connect_error', (error) => callback(error)


  change: (callback) =>
    @meshbluHttp.updateDangerously @meshbluAuth.uuid, {$inc: {timesChanged: 1}}, callback

module.exports = EmitterDevice
