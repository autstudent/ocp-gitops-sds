oc delete vs direct-nginx-through-egress-gateway -n user1
oc delete dr egressgateway-for-nginx -n user1
oc delete gw istio-egressgateway -n user1
oc delete secret -n istio-system user1-mesh-external-egress-nginx-client-certs
oc delete dr -n istio-system  originate-mtls-for-nginx-user1