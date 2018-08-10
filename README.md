**Deployment Instructions**

On a clean Ubuntu 16.04 machine, bootstrap the installation by running the following commands as root:
```
WHERE_THE_ORCHESTRATOR_IS='https://github.com/Morphl-Project/MorphL-Orchestrator'
WHERE_THE_SOFTWARE_IS='https://github.com/Morphl-Project/Sample-Code'

apt update -qq && apt -y install git ca-certificates
git clone ${WHERE_THE_ORCHESTRATOR_IS} /opt/orchestrator
git clone ${WHERE_THE_SOFTWARE_IS} /opt/samplecode
bash /opt/orchestrator/bootstrap/runasroot/rootbootstrap.sh

```
Log out and log back in.
