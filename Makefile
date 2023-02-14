DEV_GCP_PROJECT_ID=test-project

GKE_CLUSTER_VERSION=1.22.15-gke.1000

GKE_CLUSTER_NAME=test-cluster

dev/gcp/project/check:
	 if [ `gcloud config list 2> /dev/null | grep "project = ${DEV_GCP_PROJECT_ID}" | wc -l` -eq 0 ]; then >&2 echo "ERROR: project is not ${DEV_GCP_PROJECT_ID}"; exit 1; fi

# GCE 料金については以下を参照。
# ref. https://cloud.google.com/compute/all-pricing
dev/gke/cluster/create: dev/gcp/project/check
	gcloud container clusters create ${GKE_CLUSTER_NAME} \
		--cluster-version ${GKE_CLUSTER_VERSION} \
		--machine-type e2-small \
		--num-nodes 3 \
		--disk-size 10GB \
		--zone us-west1-a \
		--node-locations us-west1-a

# もし pv, pvc の利用があった場合は明示的 kubectl delete pvc としてあげたほうがいい。
dev/gke/cluster/delete: dev/gcp/project/check
	gcloud container clusters delete ${GKE_CLUSTER_NAME} \
		--zone us-west1-a

dev/helm/v2/init: dev/gcp/project/check
	kubectl apply -f k8s/kube-system/tiller-clusterrolebinding.yaml
	helm-v2.17.0 init --service-account tiller --tiller-namespace kube-system

# secret を作成しておかないとデプロイできない
# kubectl create secret generic atlantis-vcs --from-file=github_token --from-file=github_secret
# kubectl create secret generic prow-github-token --from-file=token
# kubectl create secret generic prow-hmac-token --from-file=hmac
# kubectl create secret generic prow-gcs-credentials --from-file=service-account.json
dev/helm/v2/install: dev/gcp/project/check
	helm-v2.17.0 upgrade atlantis ./k8s/default/atlantis -f ./k8s/default/atlantis-values.yaml --install --recreate-pods
	helm-v2.17.0 upgrade concourse ./k8s/default/concourse -f ./k8s/default/concourse-values.yaml --install --recreate-pods
	helm-v2.17.0 upgrade prow ./k8s/default/prow -f ./k8s/default/prow-values.yaml --install --recreate-pods
