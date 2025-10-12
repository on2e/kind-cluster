# KIND Cluster

This repository includes:

- [KIND](https://github.com/kubernetes-sigs/kind) cluster configuration file along with convenience scripts for creating/deleting a KIND cluster
- Kubernetes deployment manifests for various applications to facilitate local testing of new workloads in KIND
- GitHub Actions workflow that automatically renders manifests on each change for improved visibility [(Rendered Manifests Pattern)](https://akuity.io/blog/the-rendered-manifests-pattern)
- [Renovate](https://github.com/renovatebot/renovate/tree/main) configuration for keeping everything up to date (KIND node image, upstream Kubernetes resource dependencies)
