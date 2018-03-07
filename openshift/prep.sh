#!/usr/bin/env bash

oc create serviceaccount wap-game
oc policy add-role-to-user view -z wap-game
oc adm policy add-scc-to-user anyuid -z wap-game

oc create serviceaccount wap-admin
oc policy add-role-to-user edit -z wap-admin
oc adm policy add-cluster-role-to-user view -z wap-admin
