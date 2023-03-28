Ce document l'installation de Gitlab CE qui nous servira de référentiel Git pour la suite de cette formation sur OpenShift. 
Il est supposé que l'éxécution des commandes ci-dessous s'effectue avec le compte root (EUID=0)

## Installation 

##### Installation des dépendances 
```sh
dnf install -y policycoreutils-python3 curl openssh-server
```


##### Service de notification Postfix 
```sh
dnf install -y postfix
systemctl start postfix && systemctl enable --now postfix && systemctl status postfix
```


##### Ajout du repo Gitlab
```sh
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | bash
```


##### Installation du package Gitlab-CE
```sh
EXTERNAL_URL="http://gitlab.eazytraining.lab" dnf -y install gitlab-ce
```


##### Configuration Firewall
```sh
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
systemctl reload firewalld
```


## Configuration initiale de GitLab 

Il faudra en premier lieu récupérer le mot de passe initial du compte root dans le fichier `/opt/gitlab/initial_root_password`. 
Puis ensuite se connecter à l'instance GitLab **http://gitlab.eazytraining.lab** 