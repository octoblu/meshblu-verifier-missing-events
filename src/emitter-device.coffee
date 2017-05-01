MeshbluWebsocket  = require 'meshblu-websocket'
MeshbluFirehose   = require 'meshblu-firehose-socket.io'
MeshbluConfig     = require 'meshblu-config'
{EventEmitter2}   = require 'eventemitter2'
_                 = require 'lodash'
class EmitterDevice extends EventEmitter2

  constructor: (@meshbluAuth) ->
    meshbluWebsocketAuth          = _.cloneDeep @meshbluAuth
    meshbluWebsocketAuth.resolveSrv = true
    meshbluWebsocketAuth.port     = process.env.MESHBLU_WEBSOCKET_PORT
    # meshbluWebsocketAuth.protocol = 'ws'
    @meshbluAuth.port             = process.env.MESHBLU_FIREHOSE_PORT
    # @meshbluAuth.protocol         = 'http'

    console.log JSON.stringify {meshbluWebsocketAuth}
    @meshbluWebsocket = new MeshbluWebsocket meshbluWebsocketAuth

    @firehose = new MeshbluFirehose meshbluConfig: @meshbluAuth
    @firehose.on 'message', (data) =>
      @emit 'message', data

    @firehose.on 'error', (error) => console.error 'error', error.stack

  listen: (callback) =>
    @firehose.connect()
    @firehose.once 'connect', =>
      console.log 'firehose connected'
      @meshbluWebsocket.connect callback

    @firehose.once 'connect_error', (error) => callback(error)
    @meshbluWebsocket.once 'connect_error', (error) => callback(error)

  change: (callback) =>
    console.log ''
    @meshbluWebsocket.once 'updated', callback
    @meshbluWebsocket.updateDangerously uuid: @meshbluAuth.uuid, {$inc: {timesChanged: 1}}

module.exports = EmitterDevice
