MeshbluWebsocket  = require 'meshblu-websocket'
MeshbluFirehose   = require 'meshblu-firehose-socket.io'
MeshbluConfig     = require 'meshblu-config'
{EventEmitter2}   = require 'eventemitter2'

class EmitterDevice extends EventEmitter2

  constructor: (@meshbluAuth) ->
    @meshbluWebsocket = new MeshbluWebsocket @meshbluAuth
    console.log {@meshbluAuth}
    @firehose = new MeshbluFirehose meshbluConfig: @meshbluAuth
    @firehose.on 'message', (data) =>
      @emit 'message', data

    @firehose.on 'error', (error) => console.error 'error', error.stack

  listen: (callback) =>
    @firehose.connect()
    @firehose.once 'connect', =>
      @meshbluWebsocket.connect callback

    @firehose.once 'connect_error', (error) => callback(error)
    @meshbluWebsocket.once 'connect_error', (error) => callback(error)

  change: (callback) =>
    console.log 'changing'
    @meshbluWebsocket.once 'updated', callback
    @meshbluWebsocket.updateDangerously uuid: @meshbluAuth.uuid, {$inc: {timesChanged: 1}}

module.exports = EmitterDevice
