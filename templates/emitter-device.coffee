module.exports = ({subscriberUuid}) =>
  type: 'missing-events-verifier:emitter'
  meshblu:
    version: '2.0.0'
    whitelists:
      configure:
        sent: [{uuid: subscriberUuid}]
