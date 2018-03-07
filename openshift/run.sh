PROJ=$(oc project -q)
oc new-app --docker-image=cloudowski/whackapod-game -l stack=whackapod
oc new-app --docker-image=cloudowski/whackapod-admin -l stack=whackapod --env="APIIMAGE=cloudowski/whackapod-api"
oc new-app --docker-image=cloudowski/whackapod-api -l stack=whackapod

oc patch dc/whackapod-admin --patch '{"spec":{"template":{"spec":{"serviceAccountName": "wap-admin"}}}}'
oc patch dc/whackapod-game --patch '{"spec":{"template":{"spec":{"serviceAccountName": "wap-game"}}}}'


oc expose dc/whackapod-admin --port=8080
oc expose dc/whackapod-game --port=8080
oc expose dc/whackapod-api --port=8080
oc expose svc/whackapod-game --path=/ --port=8080

sleep 5
GAMEHOST=$(oc get route whackapod-game -o=jsonpath='{.status.ingress[0].host}')

oc expose svc/whackapod-admin --hostname=$GAMEHOST --path=/admin
oc expose svc/whackapod-api --hostname=$GAMEHOST --path=/api

oc set env dc whackapod-admin GAMENAMESPACE=${PROJ}
