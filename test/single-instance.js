'use strict'

const Lab = require('@hapi/lab')
const Mongoose = require('mongoose')
const { expect } = require('@hapi/code')
const { describe, it } = (exports.lab = Lab.script())
const { MONGODB_USERNAME = null, MONGODB_PASSWORD = null } = process.env

if (null == MONGODB_USERNAME) {
  describe('MongoDB Single Instance ->', () => {
    it('connects to MongoDB', async () => {
      await expect(
        Mongoose.connect('mongodb://localhost', {
          useNewUrlParser: true,
          useUnifiedTopology: true
        })
      ).to.not.reject()
    })

    it('fails to connect to non-existent MongoDB instance', async () => {
      await expect(
        Mongoose.connect('mongodb://localhost:27018', {
          useNewUrlParser: true,
          useUnifiedTopology: true,
          connectTimeoutMS: 1000,
          serverSelectionTimeoutMS: 1000
        })
      ).to.reject()
    })
  })
} else {
  describe('MongoDB Single Instance with credentials ->', () => {
    it('connects to MongoDB', async () => {
      await expect(
        Mongoose.connect(`mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@localhost`, {
          useNewUrlParser: true,
          useUnifiedTopology: true
        })
      ).to.not.reject()
    })

    it('fails to connect to non-existent MongoDB instance', async () => {
      await expect(
        Mongoose.connect(`mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@localhost:27018`, {
          useNewUrlParser: true,
          useUnifiedTopology: true,
          connectTimeoutMS: 1000,
          serverSelectionTimeoutMS: 1000
        })
      ).to.reject()
    })
  })
}
