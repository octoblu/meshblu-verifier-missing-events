_                   = require 'lodash'
MeshbluFirehose     = require 'meshblu-firehose-socket.io'
MeshbluHttp         = require 'meshblu-http'
MeshbluConfig       = require 'meshblu-config'
EmitterTemplate     = require './templates/emitter-device'
SubscriberTemplate  = require './templates/subscriber-device'

class MissingEventsVerifier
  setupDevices: (callback) =>
    meshbluHttp = new MeshbluHttp new MeshbluConfig().toJSON()
    meshbluHttp.register SubscriberTemplate(), (error, @subscriberAuth) =>
      return callback error if error?
      meshbluHttp.register EmitterTemplate({@subscriberAuth}), (error, @emitterAuth) =>
        return callback error if error?
        @setupSubscriptions callback

  setupSubscriptions: (callback) =>
    subscriberMeshblu = new MeshbluHttp @subscriberAuth
    subscriberMeshblu.whoami (error, subscriber) =>
      console.log JSON.stringify {error, subscriber}, null, 2

    emitterMeshblu = new MeshbluHttp @emitterAuth
    emitterMeshblu.whoami (error, emitter) =>
      console.log JSON.stringify {error, emitter}, null, 2



module.exports = MissingEventsVerifier
