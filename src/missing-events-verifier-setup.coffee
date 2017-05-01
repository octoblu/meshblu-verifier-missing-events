_                   = require 'lodash'
async               = require 'async'
MeshbluHttp         = require 'meshblu-http'
MeshbluConfig       = require 'meshblu-config'
EmitterTemplate     = require '../templates/emitter-template'
SubscriberTemplate  = require '../templates/subscriber-template'

class MissingEventsVerifierSetup
  setupDevices: (callback) =>
    console.log 'setting up devices'
    meshbluHttp = new MeshbluHttp new MeshbluConfig().toJSON()
    console.log 'register subscriber'
    @meshbluHttpDefaults =
      port: process.env.MESHBLU_PORT
      hostname: process.env.MESHBLU_HOSTNAME
      protocol: process.env.MESHBLU_PROTOCOL

    meshbluHttp.register SubscriberTemplate(), (error, @subscriberAuth) =>
      return callback error if error?
      console.log 'register emitter'
      meshbluHttp.register EmitterTemplate({subscriberUuid: @subscriberAuth.uuid}), (error, @emitterAuth) =>
        return callback error if error?
        console.log 'setup subscriptions'
        @setupSubscriptions callback

  setupSubscriptions: (callback) =>
    @_setupEmitterSubscriptions (error) =>
      return callback error if error?

      @_setupSubscriberSubscriptions (error) =>
        return callback error if error?

        subscriberAuth          = _.pick @subscriberAuth, 'uuid', 'token'
        subscriberAuth.hostname = process.env.MESHBLU_HOSTNAME

        emitterAuth          = _.pick @emitterAuth, 'uuid', 'token'
        emitterAuth.hostname = process.env.MESHBLU_HOSTNAME

        console.log {subscriberAuth, emitterAuth}
        return callback null, {subscriberAuth, emitterAuth}

  _setupEmitterSubscriptions: (callback) =>
    emitterMeshblu = new MeshbluHttp _.extend {}, @emitterAuth, @meshbluHttpDefaults
    emitterSubscriptions = [
      {subscriberUuid: @emitterAuth.uuid, emitterUuid: @emitterAuth.uuid, type: 'configure.sent'}
      {subscriberUuid: @emitterAuth.uuid, emitterUuid: @emitterAuth.uuid, type: 'configure.received'}
    ]

    async.each emitterSubscriptions, emitterMeshblu.createSubscription, callback

  _setupSubscriberSubscriptions: (callback) =>
    subscriberMeshblu = new MeshbluHttp _.extend {}, @subscriberAuth, @meshbluHttpDefaults
    subscriberSubscriptions = [
      {subscriberUuid: @subscriberAuth.uuid, emitterUuid: @emitterAuth.uuid, type: 'configure.sent'}
      {subscriberUuid: @subscriberAuth.uuid, emitterUuid: @subscriberAuth.uuid, type: 'configure.received'}
    ]
    async.each subscriberSubscriptions, subscriberMeshblu.createSubscription, callback

module.exports = MissingEventsVerifierSetup
