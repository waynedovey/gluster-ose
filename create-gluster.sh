#!/bin/bash

oc create -f gluster-service.yaml
oc create -f gluster-endpoints.yaml
