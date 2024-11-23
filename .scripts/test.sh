#!/bin/sh -e

java -jar WireMock/wire-mock.jar --root-dir WireMock --port 8080 > /dev/null &

while ! lsof -i :8080 > /dev/null; do
  echo "Oczekiwanie na WireMock..."
  sleep 1
done

echo "ok"

curl http://localhost:8080/pjp-api/rest/station/findAll