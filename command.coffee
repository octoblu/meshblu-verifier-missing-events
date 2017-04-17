MissingEvents = require './missing-events-verifier'

missingEvents = new MissingEvents()


missingEvents.setupDevices (error) =>
  console.error error.stack if error?
