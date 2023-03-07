# okd-upi-install

The folders `fcos` and `rhcos` contains respectively the scripts for installing OKD and Red Hat Openshift. 

### Prerequisites - Variables

In order to perform Day2 specific actions regarding authentication, persistent storage for the internal image register, it will therefore be necessary to inject environment variables. It's best to reference all the variables so you don't forget anything.

Here is below the exhaustive list: 

- HTPASSWD_SECRET: htpasswd secret [base64]
- HTPASSWD_SECRET_NAME: name of the secret
- REGISTRY_PV_NAME: name of the persistent volume 