## NOTICE: this is a fork from [supercharge mongodb github action](https://github.com/supercharge/mongodb-github-action)

## Introduction
This GitHub Action starts a MongoDB server or MongoDB replica set. By default, the MongoDB server is available on the default port `27017`. You can configure a custom port using the `mongodb-port` input as well as other options. The examples show how to use a custom port.

This is useful when running tests against a MongoDB database.

## Usage
A code example says more than a 1000 words. Here’s an exemplary GitHub Action using a MongoDB server in versions `4.0` and `4.2` to test a Node.js app:

```yaml
name: Run tests

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [12.x, 14.x]
        mongodb-version: ['4.0', '4.2', '4.4']

    steps:
    - name: Git checkout
      uses: actions/checkout@v2

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v1
      with:
        node-version: ${{ matrix.node-version }}

    - name: Start MongoDB
      uses: supercharge/mongodb-github-action@1.6.0
      with:
        mongodb-version: ${{ matrix.mongodb-version }}

    - run: npm install

    - run: npm test
      env:
        CI: true
```

### Using a Custom MongoDB Port
You can start the MongoDB instance on a custom port. Use the `mongodb-port: 12345` input to configure port `12345` for MongoDB. Replace `12345` with the port you want to use in your test runs.

The following example starts a MongoDB server on port `42069`:

```yaml
name: Run tests

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [12.x, 14.x]
        mongodb-version: ['4.0', '4.2', '4.4']

    steps:
    - name: Git checkout
      uses: actions/checkout@v2

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v1
      with:
        node-version: ${{ matrix.node-version }}

    - name: Start MongoDB
      uses: supercharge/mongodb-github-action@1.6.0
      with:
        mongodb-version: ${{ matrix.mongodb-version }}
        mongodb-replica-set: test-rs
        mongodb-port: 42069

    - name: Install dependencies
      run: npm install

    - name: Run tests
      run: npm test
      env:
        CI: true
```

### With a Replica Set
You can run your tests against a MongoDB replica set by adding the `mongodb-replica-set: your-replicate-set-name` input. The value for `mongodb-replica-set` defines the name of your replica set. Replace `your-replicate-set-name` with the replica set name you want to use in your tests.

The following example uses the replica set name `test-rs`:

```yaml
name: Run tests

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [12.x, 14.x]
        mongodb-version: ['4.0', '4.2', '4.4']

    steps:
    - name: Git checkout
      uses: actions/checkout@v2

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v1
      with:
        node-version: ${{ matrix.node-version }}

    - name: Start MongoDB
      uses: supercharge/mongodb-github-action@1.6.0
      with:
        mongodb-version: ${{ matrix.mongodb-version }}
        mongodb-replica-set: test-rs
        mongodb-port: 42069

    - name: Install dependencies
      run: npm install

    - name: Run tests
      run: npm test
      env:
        CI: true
```

### With a username and password
You can run your tests against a MongoDB with needed username and password by adding the `mongodb-root-username: username` and `mongodb-root-password: secret` input.

```yaml
name: Run tests

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [12.x, 14.x]
        mongodb-version: ['4.0', '4.2', '4.4']

    steps:
    - name: Git checkout
      uses: actions/checkout@v2

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v1
      with:
        node-version: ${{ matrix.node-version }}

    - name: Start MongoDB
      uses: supercharge/mongodb-github-action@1.6.0
      with:
        mongodb-version: ${{ matrix.mongodb-version }}
        mongodb-root-username: admin
        mongodb-root-password: admin

    - name: Install dependencies
      run: npm install

    - name: Run tests
      run: npm test
      env:
        CI: true
```
