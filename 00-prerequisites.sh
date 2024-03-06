oc new-project istio-system
oc new-project egress-mx
oc new-project egress-es

oc apply -f istio-system-smmr.yaml
oc apply -f istio-system-smcp.yaml

oc label namespace istio-system argocd.argoproj.io/managed-by=openshift-gitops --overwrite
oc label namespace egress-mx argocd.argoproj.io/managed-by=openshift-gitops --overwrite
oc label namespace egress-es argocd.argoproj.io/managed-by=openshift-gitops --overwrite

oc new-project user1-mesh-external
oc project user1-mesh-external

oc adm policy add-scc-to-user anyuid -z nginx
oc adm policy add-scc-to-user anyuid -z nginx-es
oc adm policy add-scc-to-user anyuid -z nginx-mx

oc new-project user1
oc label namespace user1 argocd.argoproj.io/managed-by=openshift-gitops --overwrite