# tradebot end-to-end testing

The e2e testing infrastructure is powered by CircleCI and [Kubernetes Kind](https://github.com/kubernetes-sigs/kind).

### CI workflow

* download go modules
* run unit tests
* build container
* install kubectl, helm and Kubernetes Kind CLIs
* create local Kubernetes cluster with kind
* deploy Tiller on the local cluster
* load tradebot image onto the local cluster
* deploy tradebot with Helm
* run Helm tests

```yaml
jobs:
  e2e-kubernetes:
    machine: true
    steps:
      - checkout
      - run:
          name: Build tradebot container
          command: e2e/build.sh
      - run:
          name: Start Kubernetes Kind cluster
          command: e2e/bootstrap.sh
      - run:
          name: Install tradebot with Helm
          command: e2e/install.sh
      - run:
          name: Run Helm tests
          command: e2e/test.sh
```
