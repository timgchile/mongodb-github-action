'use strict'

const Lab = require('@hapi/lab')
const Mongoose = require('mongoose')
const { expect } = require('@hapi/code')
const { describe, it } = (exports.lab = Lab.script())
const { MONGODB_PORT = 27017, MONGODB_USERNAME = null, MONGODB_PASSWORD = null } = process.env

if (!MONGODB_USERNAME) {
  describe('MongoDB Instance on Custom Port ->', () => {
    it('connects to MongoDB on custom port', async () => {
      await expect(
        Mongoose.connect(`mongodb://localhost:${MONGODB_PORT}`, {
          useNewUrlParser: true,
          useUnifiedTopology: true
        })
      ).to.not.reject()
    })
  })
} else {
  describe('MongoDB Instance on Custom Port with credentials ->', () => {
    it('connects to MongoDB on custom port', async () => {
      await expect(
        Mongoose.connect(`mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@localhost:${MONGODB_PORT}`, {
          useNewUrlParser: true,
          useUnifiedTopology: true
        })
      ).to.not.reject()
    })
  })
}
