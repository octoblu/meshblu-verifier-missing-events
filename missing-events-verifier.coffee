_                   = require 'lodash'
async               = require 'async'
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

      meshbluHttp.register EmitterTemplate({subscriberUuid: @subscriberAuth.uuid}), (error, @emitterAuth) =>
        return callback error if error?
        @setupSubscriptions callback

  setupSubscriptions: (callback) =>
    @_setupEmitterSubscriptions (error) =>
      return callback error if error?

      @_setupSubscriberSubscriptions (error) =>

        emitterMeshblu = new MeshbluHttp @emitterAuth
        emitterMeshblu.subscriptions @emitterAuth.uuid, (error, subscriptions) =>
          console.log JSON.stringify subscriptions, null, 2

        subscriberMeshblu = new MeshbluHttp @subscriberAuth
        subscriberMeshblu.subscriptions @subscriberAuth.uuid, (error, subscriptions) =>
          console.log JSON.stringify subscriptions, null, 2

  _setupEmitterSubscriptions: (callback) =>
    emitterMeshblu = new MeshbluHttp @emitterAuth
    emitterSubscriptions = [
      {subscriberUuid: @emitterAuth.uuid, emitterUuid: @emitterAuth.uuid, type: 'configure.sent'}
      {subscriberUuid: @emitterAuth.uuid, emitterUuid: @emitterAuth.uuid, type: 'configure.received'}
    ]

    async.each emitterSubscriptions, emitterMeshblu.createSubscription, callback

  _setupSubscriberSubscriptions: (callback) =>
    subscriberMeshblu = new MeshbluHttp @subscriberAuth
    subscriberSubscriptions = [
      {subscriberUuid: @subscriberAuth.uuid, emitterUuid: @emitterAuth.uuid, type: 'configure.sent'}
      {subscriberUuid: @subscriberAuth.uuid, emitterUuid: @subscriberAuth.uuid, type: 'configure.received'}
    ]
    async.each subscriberSubscriptions, subscriberMeshblu.createSubscription, callback

module.exports = MissingEventsVerifier
