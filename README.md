# Haumdaucher-Kubeflow

The Haumdaucher-Kubeflow distribution assembles Kubeflow with the following goals:

* Showcasing a workflow that enables using the upstream manifests while still able to adjust certain things.
* Tailored to be used on one server. Therefore *resource requests* are removed, as they make no sense in this case. **The admin has to assure the server is big enough!**

There are different sizes of the cluster that may be installed:
* small
    * istio, dex, oauth, cert-manager, kubeflow namespace and roles
    * jupyter web app
    * notebook controller
    * profiles & KFAM
    * Volumes web app
    * Kubeflow pipelines

## How it works

Kustomize is used to pull in external manifests from kubeflow/manifests repository, overlays are used from within this repository.

## example installation with minikube

On a macbook. Taken from the [kubeflow/manifests README](https://github.com/kubeflow/manifests/blob/v1.3-branch/README.md).

Use [kzenv](https://github.com/nlamirault/kzenv) to switch to kustomize 3.2.0 !

```sh
brew tap nlamirault/kzenv https://github.com/nlamirault/kzenv/
# remove "normal" kustomize
brew remove kustomize
brew install kzenv
kzenv install 3.2.0
kzenv use 3.2.0
kustomize version
```

Then use the following commands to install Kubeflow to minikube.

```sh
# tag of the Kubeflow version
minikube start --driver=hyperkit --addons=ingress,metrics-server --memory=14g --cpus=8 --disk-size='40000mb' && \
while ! kustomize build --load_restrictor=none small | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done && \
sleep 600 && \
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```

This may take up to an hour, depending on your internet connnection. Even when connection via istio-ingressgateway is already possible, some functions might not work.

Login on [http://127.0.0.1:8080](http://127.0.0.1:8080)(or something else, see above) using *user@example.com:12341234*.

Tear down:

```sh
minikube delete
cd ..
rm -rf manifests
```