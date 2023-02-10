DEV_GCP_PROJECT_ID=playground-361304

GKE_CLUSTER_VERSION=1.22.15-gke.1000

GKE_CLUSTER_NAME=test-cluster

dev/gcp/project/check:
	 if [ `gcloud config list 2> /dev/null | grep "project = playground-361304" | wc -l` -eq 0 ]; then >&2 echo "ERROR: project is not tb-dev"; exit 1; fi

# GCE 料金については以下を参照。
# ref. https://cloud.google.com/compute/all-pricing
dev/gke/cluster/create: dev/gcp/project/check
	gcloud container clusters create ${GKE_CLUSTER_NAME} \
		--cluster-version ${GKE_CLUSTER_VERSION} \
		--machine-type e2-micro \
		--num-nodes 1 \
		--disk-size 10GB \
		--zone us-west1-a \
		--node-locations us-west1-a

# もし pv, pvc の利用があった場合は明示的 kubectl delete pvc としてあげたほうがいい。
# ref. https://www.notion.so/4b14d440262f4bc49999c846237ad4ce
dev/gke/cluster/delete: dev/gcp/project/check
	gcloud container clusters delete ${GKE_CLUSTER_NAME} \
		--zone us-west1-a

dev/gke/setup: \
	dev/gcp/project/check \
	dev/gke/cluster/create

helm/init:
	kubectl apply -f k8s/kube-system/tiller-clusterrolebinding.yaml
	helm init --service-account tiller --tiller-namespace kube-system

helm/install: \
	helm-v2.17.0 upgrade atlantis stable/atlantis -f k8s/default/atlantis.yaml --version 3.8.2 --install --recreate-pods
