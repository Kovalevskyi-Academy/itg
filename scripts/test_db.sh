#!/usr/bin/env bash
set -Eeuo pipefail
pg_pod_name=$(kubectl get pod --selector=app=pg -o jsonpath={.items..metadata.name})
is_pod_started=unknown
waitTime=3

while [ "${is_pod_started}" != "true" ]
do
  echo "TEST CYCLE"
  # possible pod conditions.status: "true", "false", or "unknown"
  is_pod_started=$(kubectl get pod "${pg_pod_name}" -o jsonpath={.status..started})
  echo "sleeping on $waitTime seconds" && sleep "${waitTime}"
  waitTime=$(( "${waitTime}" + 1 ))
  if [ "${waitTime}" -gt 50 ]; then
    echo "DB is unavailable!"
    exit 1
  fi
done

echo "PG IS STARTED!"

kubectl exec "${pg_pod_name}" -- /bin/sh -c "pgbench -i -U ${PG_DEV_USERNAME} -d ${PG_DEV_DB_NAME}"
echo "DB TEST SUCCESS"
