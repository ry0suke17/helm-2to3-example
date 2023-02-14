# helm-2to3-example

This repository is for trying helm 2to3.

## Setup

Set up the environment with the following cmds.

```shell
make dev/gke/cluster/create DEV_GCP_PROJECT_ID=your-project

make dev/helm/v2/init DEV_GCP_PROJECT_ID=your-project

# create the necessary secret for each service.

make dev/helm/v2/install DEV_GCP_PROJECT_ID=your-project
```

## Try 2to3

See below to try 2to3.

- https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/

```shell
helm3 plugin install https://github.com/helm/helm-2to3

helm3 2to3 move config --dry-run
helm3 2to3 move config

helm3 2to3 convert --dry-run your-release
helm3 2to3 convert your-release

helm3 2to3 cleanup --dry-run
helm3 2to3 cleanup
```