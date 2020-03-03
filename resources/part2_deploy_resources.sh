#!/bin/bash
#
# author: Gary A. Stafford
# site: https://programmaticponderings.com
# license: MIT License
# purpose: Deploy Kubernetes/Istio resources

# Constants
readonly NAMESPACES=(default)
readonly SERVICES=(a b c a d e f g h)

#kubectl apply -f ./resources/other/namespaces.yaml
#kubectl apply -f ./resources/other/istio-gateway.yaml

#kubectl apply -f ./resources/other/service-a-hpa.yaml

#kubectl apply -f ../golang-srv-demo-secrets/other/external-mesh-mongodb-atlas.yaml
#kubectl apply -f ../golang-srv-demo-secrets/other/external-mesh-cloudamqp.yaml


for namespace in ${NAMESPACES[@]}; do
  # Enable automatic Istio sidecar injection
  kubectl label namespace ${namespace} istio-injection=enabled

  kubectl apply -n ${namespace} -f ./secret/go-srv-demo.yaml

  for service in ${SERVICES[@]}; do
    kubectl apply -n ${namespace} -f ./services/service-$service.yaml
  done
  kubectl apply -n ${namespace} -f ./services/service-mongo.yaml
  kubectl apply -n ${namespace} -f ./services/service-rabbitmq.yaml
done
