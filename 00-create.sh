openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout example.com.key -out example.com.crt
openssl req -out my-nginx.user1-mesh-external.svc.cluster.local.csr -newkey rsa:2048 -nodes -keyout my-nginx.user1-mesh-external.svc.cluster.local.key -subj "/CN=my-nginx.user1-mesh-external.svc.cluster.local/O=some organization"
openssl x509 -req -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in my-nginx.user1-mesh-external.svc.cluster.local.csr -out my-nginx.user1-mesh-external.svc.cluster.local.crt

openssl req -out client.example.com.csr -newkey rsa:2048 -nodes -keyout client.example.com.key -subj "/CN=client.example.com/O=client organization"
openssl x509 -req -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 1 -in client.example.com.csr -out client.example.com.crt

oc new-project user1-mesh-external
oc project user1-mesh-external
oc create sa nginx
oc adm policy add-scc-to-user anyuid -z nginx
oc create -n user1-mesh-external secret tls nginx-server-certs --key my-nginx.user1-mesh-external.svc.cluster.local.key --cert my-nginx.user1-mesh-external.svc.cluster.local.crt

oc create -n user1-mesh-external secret generic nginx-ca-certs --from-file=example.com.crt

oc create configmap nginx-configmap -n user1-mesh-external --from-file=nginx.conf=./06-secure-egress-traffic-troubleshooting/nginx.conf

oc process -f 06-secure-egress-traffic-troubleshooting/00-nginx-svc-pod.yml --param-file=params.env --ignore-unknown-parameters | oc apply -f - -n user1-mesh-external

oc get pods -n user1-mesh-external

oc project user1-mesh-external
POD=$(oc get po -l run=my-nginx -o jsonpath='{.items[0].metadata.name}')
oc rsh $POD curl localhost:443 -k -v

oc project user1
oc create -n user1 secret tls nginx-client-certs --key client.example.com.key --cert client.example.com.crt

oc create -n user1 secret generic nginx-ca-certs --from-file=example.com.crt

oc process -f 06-secure-egress-traffic-troubleshooting/01-jump-app-sleep-svc-pod.yaml --param-file=params.env --ignore-unknown-parameters | oc apply -f - -n user1

oc project user1
POD=$(oc get po -l app=sleep -o jsonpath='{.items[0].metadata.name}')
oc exec -it $POD -c sleep -- curl -v --cacert /etc/nginx-ca-certs/example.com.crt --cert /etc/nginx-client-certs/tls.crt --key /etc/nginx-client-certs/tls.key https://my-nginx.user1-mesh-external.svc.cluster.local -k

POD=$(oc get po -l app=sleep -o jsonpath='{.items[0].metadata.name}')
oc exec -it $POD -c sleep -- curl -v https://my-nginx.user1-mesh-external.svc.cluster.local -k

oc process -f 06-secure-egress-traffic-troubleshooting/02-jump-app-egress-gw-dr.yaml --param-file=params.env --ignore-unknown-parameters | oc apply -f - -n user1

oc create secret -n istio-system generic user1-mesh-external-egress-nginx-client-certs  --from-file=tls.key=client.example.com.key  --from-file=tls.crt=client.example.com.crt  --from-file=ca.crt=example.com.crt

oc process -f 06-secure-egress-traffic-troubleshooting/03-istio-system-dr-sds.yml --param-file=params.env --ignore-unknown-parameters | oc apply -f - -n istio-system

oc project user1
POD=$(oc get po -l app=sleep -o jsonpath='{.items[0].metadata.name}')
oc exec -it $POD -c sleep -- curl -v https://my-nginx.user1-mesh-external.svc.cluster.local -k