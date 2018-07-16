**Deployment Instructions**

On a clean Ubuntu 16.04 machine, bootstrap the installation by running the following commands as root:
```
apt update -qq && apt -y install git ca-certificates
git clone https://github.com/Morphl-Project/MorphL-Orchestrator /opt/orchestrator
bash /opt/orchestrator/bootstrap/runasroot/rootbootstrap.sh

```
Log out and log back in.
