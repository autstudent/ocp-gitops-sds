oc project user1

POD=$(oc get po -l app=sleep -o jsonpath='{.items[0].metadata.name}')
oc exec -it $POD -c sleep -- curl -v --cacert /etc/nginx-ca-certs/example.com.crt --cert /etc/nginx-client-certs/tls.crt --key /etc/nginx-client-certs/tls.key https://my-nginx.user1-mesh-external.svc.cluster.local -k
oc exec -it $POD -c sleep -- curl -v --cacert /etc/nginx-ca-certs/example.com.crt --cert /etc/nginx-client-certs/tls.crt --key /etc/nginx-client-certs/tls.key https://my-nginx-es.user1-mesh-external.svc.cluster.local -k
oc exec -it $POD -c sleep -- curl -v --cacert /etc/nginx-ca-certs/example.com.crt --cert /etc/nginx-client-certs/tls.crt --key /etc/nginx-client-certs/tls.key https://my-nginx-mx.user1-mesh-external.svc.cluster.local -k

POD=$(oc get po -l app=sleep -o jsonpath='{.items[0].metadata.name}')
oc exec -it $POD -c sleep -- curl -v http://my-nginx.user1-mesh-external.svc.cluster.local -k
oc exec -it $POD -c sleep -- curl -v http://my-nginx-es.user1-mesh-external.svc.cluster.local -k
oc exec -it $POD -c sleep -- curl -v http://my-nginx-mx.user1-mesh-external.svc.cluster.local -k

POD=$(oc get po -l app=sleep -o jsonpath='{.items[0].metadata.name}')
oc exec -it $POD -c sleep -- curl -v http://my-nginx-mx.user1-mesh-external.svc.cluster.local -k