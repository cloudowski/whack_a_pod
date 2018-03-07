oc create serviceaccount game
oc policy add-role-to-user view -z game
oc adm policy add-scc-to-user anyuid -z game
