#!/usr/bin/env bash

PROJ=$(oc project -q)
oc new-app --docker-image=cloudowski/whackapod-game -l stack=whackapod
oc new-app --docker-image=cloudowski/whackapod-admin -l stack=whackapod --env="APIIMAGE=cloudowski/whackapod-api"
kubectl run api-deployment --image=cloudowski/whackapod-api --replicas=1 --port=8080 --labels="app=api"

oc patch dc/whackapod-admin --patch '{"spec":{"template":{"spec":{"serviceAccountName": "wap-admin"}}}}'
oc patch dc/whackapod-game --patch '{"spec":{"template":{"spec":{"serviceAccountName": "wap-game"}}}}'


oc expose dc/whackapod-admin --port=8080
oc expose dc/whackapod-game --port=8080
#oc expose dc/api --port=8080
oc expose deployment api-deployment --name=api --port=8080  --labels="app=api"
oc expose svc/whackapod-game --path=/ --port=8080

sleep 5
GAMEHOST=$(oc get route whackapod-game -o=jsonpath='{.status.ingress[0].host}')

oc expose svc/whackapod-admin --hostname=$GAMEHOST --path=/admin
oc expose svc/api --hostname=$GAMEHOST --path=/api

oc set env dc whackapod-admin GAMENAMESPACE=${PROJ}

oc set probe deployment/api-deployment --readiness --liveness --get-url=http://:8080/healthz
oc set probe dc/whackapod-admin --readiness --liveness --get-url=http://:8080/healthz
oc set probe dc/whackapod-game --readiness --liveness --get-url=http://:8080/
