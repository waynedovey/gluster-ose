#!/bin/bash

oc project default
oc create -f gluster-service.yaml
oc create -f gluster-endpoints.yaml
