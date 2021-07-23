#!/usr/bin/env sh

# Map input values from the GitHub Actions workflow to shell variables
MONGODB_VERSION=${1}
MONGODB_REPLICA_SET=${2}
MONGODB_PORT=${3}
MONGODB_ROOT_USERNAME=${4}
MONGODB_ROOT_PASSWORD=${5}

AUTH_PARAMETERS=""

if [ -z "${MONGODB_VERSION}" ]; then
  echo ""
  echo "Missing MongoDB version in the [mongodb-version] input. Received value: ${MONGODB_VERSION}"
  echo ""

  exit 2
fi

if [ -z "${MONGODB_REPLICA_SET}" ]; then
  echo "::group::Starting single-node instance, no replica set"
  echo "  - port [${MONGODB_PORT}]"
  echo "  - version [${MONGODB_VERSION}]"
  if [ "${MONGODB_ROOT_USERNAME}" != "" ]; then
    echo "  - username [${MONGODB_ROOT_USERNAME}]"
    echo "  - password [${MONGODB_ROOT_PASSWORD}]"
    AUTH_PARAMETERS="--username ${MONGODB_ROOT_USERNAME} --password ${MONGODB_ROOT_PASSWORD} --authenticationDatabase=admin"
  fi
  echo ""
  echo "::endgroup::"

  if [ -z "${MONGODB_ROOT_USERNAME}" ]; then
    docker run --name mongodb --publish "${MONGODB_PORT}":"${MONGODB_PORT}" --detach mongo:"${MONGODB_VERSION}" --port "${MONGODB_PORT}"
  else
    docker run --name mongodb --publish "${MONGODB_PORT}":"${MONGODB_PORT}" --detach --env MONGO_INITDB_ROOT_USERNAME="${MONGODB_ROOT_USERNAME}" --env MONGO_INITDB_ROOT_PASSWORD="${MONGODB_ROOT_PASSWORD}" mongo:"${MONGODB_VERSION}" --port "${MONGODB_PORT}"
  fi

  echo "::group::Waiting for MongoDB to accept connections"
  sleep 1
  TIMER=0

  until docker exec --tty mongodb mongo --port "${MONGODB_PORT}" ${AUTH_PARAMETERS} --eval "db.serverStatus()"
  do
    sleep 1
    echo "."
    TIMER=$((TIMER + 1))

    if [[ ${TIMER} -eq 20 ]]; then
      echo "MongoDB did not initialize within 20 seconds. Exiting."
      exit 2
    fi
  done
  echo "::endgroup::"

  echo "::group::Testing connection to database"
  docker exec --tty mongodb mongo --port "${MONGODB_PORT}" ${AUTH_PARAMETERS} --eval "
    db.getCollectionInfos()
  " test
  echo ""
  echo "::endgroup::"

  exit
fi

echo "::group::Starting MongoDB as single-node replica set"
echo "  - port [${MONGODB_PORT}]"
echo "  - version [${MONGODB_VERSION}]"
echo "  - replica set [${MONGODB_REPLICA_SET}]"
if [ "${MONGODB_ROOT_USERNAME}" != "" ]; then
  echo "  - username [${MONGODB_ROOT_USERNAME}]"
  echo "  - password [${MONGODB_ROOT_PASSWORD}]"
fi
echo ""

if [ -z "${MONGODB_ROOT_USERNAME}" ]; then
  docker run --name mongodb --publish "${MONGODB_PORT}":"${MONGODB_PORT}" --detach mongo:"${MONGODB_VERSION}" mongod --replSet "${MONGODB_REPLICA_SET}" --port "${MONGODB_PORT}"
else
  docker run --name mongodb --publish "${MONGODB_PORT}":"${MONGODB_PORT}" --detach mongo:"${MONGODB_VERSION}" --env MONGO_INITDB_ROOT_USERNAME="${MONGODB_ROOT_USERNAME}" --env MONGO_INITDB_ROOT_PASSWORD="${MONGODB_ROOT_PASSWORD}" mongod --replSet "${MONGODB_REPLICA_SET}" --port "${MONGODB_PORT}"
fi
echo "::endgroup::"

echo "::group::Waiting for MongoDB to accept connections"
sleep 1
TIMER=0

until docker exec --tty mongodb mongo --port "${MONGODB_PORT}" ${AUTH_PARAMETERS} --eval "db.serverStatus()"
do
  sleep 1
  echo "."
  TIMER=$((TIMER + 1))

  if [[ ${TIMER} -eq 20 ]]; then
    echo "MongoDB did not initialize within 20 seconds. Exiting."
    exit 2
  fi
done
echo "::endgroup::"

echo "::group::Initiating replica set [${MONGODB_REPLICA_SET}]"

docker exec --tty mongodb mongo --port "${MONGODB_PORT}" ${AUTH_PARAMETERS} --eval "
  rs.initiate({
    \"_id\": \"${MONGODB_REPLICA_SET}\",
    \"members\": [ {
       \"_id\": 0,
      \"host\": \"localhost:${MONGODB_PORT}\"
    } ]
  })
"
echo "Success! Initiated replica set [${MONGODB_REPLICA_SET}]"
echo "::endgroup::"

echo "::group::Checking replica set status [${MONGODB_REPLICA_SET}]"
docker exec --tty mongodb mongo --port "${MONGODB_PORT}" ${AUTH_PARAMETERS} --eval "
  rs.status()
"
echo "::endgroup::"
